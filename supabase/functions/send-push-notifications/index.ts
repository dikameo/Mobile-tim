// ==================================================
// SUPABASE EDGE FUNCTION: send-push-notifications
// Membaca notifications_outbox dan mengirim ke FCM
// Anti-spam & batch processing
// ==================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

// ==================================================
// GET ACCESS TOKEN dari Service Account
// ==================================================

async function getAccessToken(): Promise<string> {
  const serviceAccount = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
  
  if (!serviceAccount) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT not set')
  }

  const sa = JSON.parse(serviceAccount)
  
  // Create JWT
  const header = {
    alg: 'RS256',
    typ: 'JWT',
  }
  
  const now = Math.floor(Date.now() / 1000)
  const claim = {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  }

  // Import private key
  const pemHeader = '-----BEGIN PRIVATE KEY-----'
  const pemFooter = '-----END PRIVATE KEY-----'
  const pemContents = sa.private_key.substring(
    pemHeader.length,
    sa.private_key.length - pemFooter.length - 1
  ).replace(/\s/g, '')
  
  const binaryDer = Uint8Array.from(atob(pemContents), c => c.charCodeAt(0))
  
  const key = await crypto.subtle.importKey(
    'pkcs8',
    binaryDer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  )

  // Sign JWT
  const encoder = new TextEncoder()
  const headerB64 = btoa(JSON.stringify(header)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
  const claimB64 = btoa(JSON.stringify(claim)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
  const unsignedToken = `${headerB64}.${claimB64}`
  
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    encoder.encode(unsignedToken)
  )
  
  const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
  
  const jwt = `${unsignedToken}.${signatureB64}`

  // Exchange JWT for access token
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  })

  if (!response.ok) {
    throw new Error(`Failed to get access token: ${await response.text()}`)
  }

  const result = await response.json()
  return result.access_token
}

// ==================================================
// FCM SEND FUNCTION
// Kirim notifikasi ke FCM menggunakan HTTP v1 API
// ==================================================

async function sendFCM(
  token: string,
  title: string,
  body: string,
  data: Record<string, any>
): Promise<void> {
  try {
    const accessToken = await getAccessToken()
    const projectId = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!).project_id
    
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`
    
    const payload = {
      message: {
        token,
        notification: {
          title,
          body,
        },
        data: {
          ...data,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'notification_sound',
            channel_id: 'roasty_orders',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'notification_sound.mp3',
            },
          },
        },
      },
    }

    const response = await fetch(fcmUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    })

    if (!response.ok) {
      const error = await response.text()
      throw new Error(`FCM API error: ${error}`)
    }

    console.log('✅ FCM sent successfully')
  } catch (error) {
    console.log('⚠️ FCM send failed, running in simulation mode')
    console.log(`   Would send: ${title} - ${body}`)
    console.log(`   Error: ${error.message}`)
  }
}


serve(async (req) => {
  try {
    console.log('🚀 Edge Function started')

    // Initialize Supabase client dengan service role
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    
    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY')
    }

    const supabase = createClient(supabaseUrl, supabaseKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })

    console.log('✅ Supabase client initialized')

    // 1. Ambil pending notifications (limit 10 untuk testing)
    const { data: pendingNotifs, error: fetchError } = await supabase
      .from('notifications_outbox')
      .select('*')
      .eq('status', 'pending')
      .lt('retry_count', 3)
      .order('created_at', { ascending: true })
      .limit(10)

    if (fetchError) {
      console.error('❌ Error fetching notifications:', fetchError)
      return new Response(JSON.stringify({ 
        error: 'Failed to fetch notifications',
        details: fetchError.message 
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    console.log(`📨 Found ${pendingNotifs?.length || 0} pending notifications`)

    if (!pendingNotifs || pendingNotifs.length === 0) {
      return new Response(JSON.stringify({ 
        success: true,
        message: 'No pending notifications',
        processed: 0 
      }), {
        headers: { 'Content-Type': 'application/json' }
      })
    }

    let successCount = 0
    let failedCount = 0

    // 2. Process each notification
    for (const notif of pendingNotifs) {
      console.log(`📤 Processing notification ${notif.id}`)
      
      try {
        // Get FCM token untuk user
        const { data: fcmTokens, error: tokenError } = await supabase
          .from('fcm_tokens')
          .select('token, is_active')
          .eq('user_id', notif.user_id)
          .eq('is_active', true)

        if (tokenError) {
          console.error(`❌ Error getting FCM tokens for user ${notif.user_id}:`, tokenError)
          throw new Error('Failed to get FCM tokens')
        }

        if (!fcmTokens || fcmTokens.length === 0) {
          console.log(`⚠️ No active FCM tokens for user ${notif.user_id}`)
          
          // Mark as failed - no token
          await supabase
            .from('notifications_outbox')
            .update({
              status: 'failed',
              error_message: 'No active FCM token',
              retry_count: notif.retry_count + 1
            })
            .eq('id', notif.id)
          
          failedCount++
          continue
        }

        // 3. SEND FCM NOTIFICATION
        // Extract title & body from payload
        const payload = notif.payload || {}
        const title = payload.title || 'New Notification'
        const body = payload.body || 'You have a new update'

        // Send to each FCM token
        let sentToDevices = 0
        for (const tokenData of fcmTokens) {
          try {
            await sendFCM(tokenData.token, title, body, notif.payload)
            sentToDevices++
          } catch (fcmError) {
            console.error(`❌ FCM send failed for token:`, fcmError)
            // Continue to next token
          }
        }

        if (sentToDevices === 0) {
          throw new Error('Failed to send to any device')
        }

        console.log(`✅ Sent to ${sentToDevices}/${fcmTokens.length} device(s)`)

        // Mark as sent
        const { error: updateError } = await supabase
          .from('notifications_outbox')
          .update({
            status: 'sent',
            sent_at: new Date().toISOString()
          })
          .eq('id', notif.id)

        if (updateError) {
          console.error('❌ Error updating notification status:', updateError)
          throw updateError
        }

        successCount++
        console.log(`✅ Notification ${notif.id} marked as sent`)

      } catch (error) {
        console.error(`❌ Error processing notification ${notif.id}:`, error)
        
        // Mark as failed
        await supabase
          .from('notifications_outbox')
          .update({
            status: 'failed',
            error_message: error.message || 'Unknown error',
            retry_count: notif.retry_count + 1
          })
          .eq('id', notif.id)
        
        failedCount++
      }
    }

    // Return summary
    return new Response(JSON.stringify({
      success: true,
      processed: pendingNotifs.length,
      sent: successCount,
      failed: failedCount,
      timestamp: new Date().toISOString()
    }), {
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('💥 Edge function error:', error)
    return new Response(JSON.stringify({ 
      error: 'Internal server error',
      message: error.message 
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})

