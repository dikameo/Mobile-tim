# API CONTRACT & PAYLOAD EXAMPLES

## ADMIN PRODUCT ENDPOINTS

### 1. GET /products (List Products)

**Supabase Query:**
```dart
var query = _client.from('products').select('*', count: CountOption.exact);
query = query.ilike('name', '%coffee%');
query = query.eq('category', 'Commercial');
query = query.eq('is_active', true);
query = query.range(0, 19).order('created_at', ascending: false);
```

**Example Response:**
```json
{
  "data": [
    {
      "id": "prod_001",
      "name": "Commercial Coffee Roaster",
      "image_url": "https://example.com/images/roaster1.jpg",
      "price": 15000000,
      "capacity": "5kg",
      "rating": 4.5,
      "review_count": 23,
      "category": "Commercial",
      "specifications": {
        "power": "3000W",
        "voltage": "220V",
        "weight": "150kg"
      },
      "description": "Professional grade coffee roaster",
      "image_urls": [
        "https://example.com/images/roaster1.jpg",
        "https://example.com/images/roaster1_2.jpg"
      ],
      "created_at": "2024-12-01T10:00:00Z",
      "updated_at": "2024-12-09T15:30:00Z",
      "created_by": "uuid-of-admin",
      "is_active": true
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 45
  }
}
```

---

### 2. POST /products (Create Product)

**Request Body:**
```json
{
  "id": "prod_002",
  "name": "Home Coffee Roaster 1kg",
  "image_url": "https://example.com/images/home-roaster.jpg",
  "price": 5000000,
  "capacity": "1kg",
  "rating": 0,
  "review_count": 0,
  "category": "1kg Capacity",
  "specifications": {
    "power": "1500W",
    "voltage": "220V",
    "weight": "25kg",
    "dimensions": "40x30x50cm"
  },
  "description": "Perfect for home use and small cafes",
  "image_urls": [
    "https://example.com/images/home-roaster.jpg",
    "https://example.com/images/home-roaster-detail.jpg"
  ],
  "is_active": true
}
```

**Response:**
```json
{
  "data": {
    "id": "prod_002",
    "name": "Home Coffee Roaster 1kg",
    "image_url": "https://example.com/images/home-roaster.jpg",
    "price": 5000000,
    "capacity": "1kg",
    "rating": 0,
    "review_count": 0,
    "category": "1kg Capacity",
    "specifications": {
      "power": "1500W",
      "voltage": "220V",
      "weight": "25kg",
      "dimensions": "40x30x50cm"
    },
    "description": "Perfect for home use and small cafes",
    "image_urls": [
      "https://example.com/images/home-roaster.jpg",
      "https://example.com/images/home-roaster-detail.jpg"
    ],
    "created_at": "2024-12-10T08:45:00Z",
    "updated_at": "2024-12-10T08:45:00Z",
    "created_by": "uuid-of-admin",
    "is_active": true
  }
}
```

---

### 3. PUT /products/:id (Update Product)

**Request Body (partial update allowed):**
```json
{
  "price": 4500000,
  "description": "Updated description with special offer",
  "is_active": true
}
```

**Response:** Same as POST response with updated fields

---

### 4. DELETE /products/:id (Soft Delete)

**Request:** No body required

**Response:**
```json
{
  "success": true
}
```

**For permanent delete, set `permanent=true` in service call**

---

## ADMIN ORDER ENDPOINTS

### 5. GET /orders (List Orders)

**Supabase Query:**
```dart
var query = _client.from('orders').select('*, profiles!orders_user_id_fkey(email, name)');
query = query.eq('status', 'processing');
query = query.or('id.ilike.%12345%,user_id.ilike.%user@email.com%');
query = query.range(0, 19).order('order_date', ascending: false);
```

**Example Response:**
```json
{
  "data": [
    {
      "id": "order_12345",
      "user_id": "uuid-user-1",
      "status": "processing",
      "subtotal": 5000000,
      "shipping_cost": 50000,
      "total": 5050000,
      "order_date": "2024-12-09T14:30:00Z",
      "shipping_address": "Jl. Sudirman No. 123, Jakarta",
      "payment_method": "Bank Transfer",
      "tracking_number": null,
      "items": [
        {
          "product_id": "prod_001",
          "product_name": "Home Coffee Roaster 1kg",
          "product_image": "https://example.com/images/home-roaster.jpg",
          "quantity": 1,
          "price_at_purchase": 5000000
        }
      ],
      "created_at": "2024-12-09T14:30:00Z",
      "updated_at": "2024-12-09T14:35:00Z",
      "profiles": {
        "email": "customer@example.com",
        "name": "John Doe"
      }
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 127
  }
}
```

---

### 6. GET /orders/:id (Get Single Order)

**Example Response:**
```json
{
  "data": {
    "id": "order_12345",
    "user_id": "uuid-user-1",
    "status": "processing",
    "subtotal": 5000000,
    "shipping_cost": 50000,
    "total": 5050000,
    "order_date": "2024-12-09T14:30:00Z",
    "shipping_address": "Jl. Sudirman No. 123, Jakarta Pusat 10210",
    "payment_method": "Bank Transfer",
    "tracking_number": null,
    "items": [
      {
        "product_id": "prod_001",
        "product_name": "Home Coffee Roaster 1kg",
        "product_image": "https://example.com/images/home-roaster.jpg",
        "quantity": 1,
        "price_at_purchase": 5000000
      }
    ],
    "created_at": "2024-12-09T14:30:00Z",
    "updated_at": "2024-12-09T14:35:00Z",
    "user_email": "customer@example.com",
    "user_name": "John Doe"
  }
}
```

---

### 7. POST /orders/:id/status (Change Order Status)

**Request Body:**
```json
{
  "status": "shipped",
  "tracking_number": "JNE123456789"
}
```

**Valid Status Transitions:**
- `pendingPayment` → `processing` or `cancelled`
- `processing` → `shipped` or `cancelled`
- `shipped` → `completed` or `cancelled`
- `completed` → (cannot change)
- `cancelled` → (cannot change)

**Response:**
```json
{
  "data": {
    "id": "order_12345",
    "user_id": "uuid-user-1",
    "status": "shipped",
    "tracking_number": "JNE123456789",
    "updated_at": "2024-12-10T09:15:00Z",
    // ... other fields
  }
}
```

**Error Response (invalid transition):**
```json
{
  "error": "Cannot change status from completed to processing"
}
```

---

## USER ORDER ENDPOINTS

### 8. GET /user/orders (User Order History)

**Supabase Query:**
```dart
final userId = SupabaseConfig.currentUser?.id;
final response = await _client
    .from('orders')
    .select('*')
    .eq('user_id', userId)
    .order('order_date', ascending: false);
```

**Example Response:**
```json
{
  "data": [
    {
      "id": "order_12345",
      "user_id": "uuid-user-1",
      "status": "shipped",
      "subtotal": 5000000,
      "shipping_cost": 50000,
      "total": 5050000,
      "order_date": "2024-12-09T14:30:00Z",
      "shipping_address": "Jl. Sudirman No. 123, Jakarta",
      "payment_method": "Bank Transfer",
      "tracking_number": "JNE123456789",
      "items": [
        {
          "product_id": "prod_001",
          "product_name": "Home Coffee Roaster 1kg",
          "product_image": "https://example.com/images/home-roaster.jpg",
          "quantity": 1,
          "price_at_purchase": 5000000
        }
      ],
      "created_at": "2024-12-09T14:30:00Z",
      "updated_at": "2024-12-10T09:15:00Z"
    },
    {
      "id": "order_12344",
      "user_id": "uuid-user-1",
      "status": "completed",
      "total": 3500000,
      // ... more fields
    }
  ]
}
```

---

### 9. GET /user/orders/:id (User Order Detail)

**Supabase Query:**
```dart
final response = await _client
    .from('orders')
    .select('*')
    .eq('id', orderId)
    .eq('user_id', userId) // Security: only own orders
    .single();
```

**Response:** Same structure as Admin order detail, but filtered to current user

---

### 10. PATCH /user/orders/:id/cancel (Cancel Order)

**Request:** No body required

**Validation:**
- Only allowed if `status == 'pendingPayment'`
- User must own the order

**Response:**
```json
{
  "data": {
    "id": "order_12346",
    "user_id": "uuid-user-1",
    "status": "cancelled",
    "updated_at": "2024-12-10T10:00:00Z",
    // ... other fields
  }
}
```

**Error Response (invalid status):**
```json
{
  "error": "Cannot cancel order with status: processing"
}
```

---

## CSV EXPORT FORMAT

**Endpoint:** Export orders to CSV

**Generated CSV:**
```csv
Order ID,User Email,Status,Subtotal,Shipping,Total,Order Date,Payment Method,Tracking Number
order_12345,customer@example.com,Dikirim,5000000,50000,5050000,2024-12-09T14:30:00Z,Bank Transfer,JNE123456789
order_12346,user2@example.com,Selesai,3500000,40000,3540000,2024-12-08T10:15:00Z,COD,
```

---

## ERROR HANDLING

**Standard Error Response:**
```json
{
  "error": "Error message here",
  "code": "ERROR_CODE",
  "details": {
    "field": "Additional error details"
  }
}
```

**Common Error Codes:**
- `INVALID_TRANSITION`: Status transition not allowed
- `NOT_FOUND`: Resource not found
- `UNAUTHORIZED`: Not authenticated or no permission
- `VALIDATION_ERROR`: Input validation failed
- `TRACKING_REQUIRED`: Tracking number required for shipped status

---

## AUTHENTICATION

All endpoints require authentication token from Supabase:

```dart
final client = SupabaseConfig.client; // Automatically includes auth token
```

**Admin-only endpoints** should verify:
```dart
final isAdmin = await SupabaseConfig.isAdmin();
if (!isAdmin) throw Exception('Unauthorized');
```

---

**END OF API CONTRACT**
