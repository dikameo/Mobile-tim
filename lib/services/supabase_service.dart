import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../config/supabase_config.dart';
import '../models/product.dart';
import 'laravel_auth_service.dart';

/// Service untuk handle Supabase operations
class SupabaseService {
  final SupabaseClient _client = SupabaseConfig.client;

  // ==================== AUTH ====================

  /// Register new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );

      if (response.user != null) {
        debugPrint('User registered successfully: ${response.user!.id}');
      }

      return response;
    } catch (e) {
      debugPrint('Error registering user: $e');
      rethrow;
    }
  }

  /// Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        debugPrint('User logged in successfully: ${response.user!.id}');
      }

      return response;
    } catch (e) {
      debugPrint('Error logging in: $e');
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
      debugPrint('User logged out successfully');
    } catch (e) {
      debugPrint('Error logging out: $e');
      rethrow;
    }
  }

  /// Get current user profile (supports both Supabase native and Laravel schema)
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      debugPrint('🔍 Getting profile for user: ${user.id}');

      // Try profiles.id first (Supabase native schema)
      var response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // If not found, try profiles.user_id (Laravel schema)
      if (response == null) {
        debugPrint('🔍 Trying user_id column...');
        response = await _client
            .from('profiles')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();
      }

      debugPrint('✅ Profile response: $response');
      return response;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  /// Check if user is admin (supports both Supabase and Laravel auth)
  Future<bool> isUserAdmin() async {
    try {
      // First check Laravel auth (if using Laravel mode)
      if (LaravelAuthService.instance.isAdmin) {
        debugPrint('🔍 Admin verified via Laravel auth');
        return true;
      }

      // Fallback to Supabase profile check
      final profile = await getUserProfile();
      final role = profile?['role'];
      debugPrint('🔍 User role check from Supabase: $role');
      return role == 'admin';
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      // If Laravel auth says admin, trust it
      return LaravelAuthService.instance.isAdmin;
    }
  }

  // ==================== PRODUCTS CRUD ====================

  /// Get all products
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _client
          .from('products')
          .select()
          .order('id', ascending: true); // Use 'id' instead of 'created_at'

      debugPrint('✅ Fetched ${response.length} products from Supabase');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error getting products: $e');
      rethrow;
    }
  }

  /// Get single product by ID
  Future<Map<String, dynamic>?> getProduct(String id) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error getting product: $e');
      return null;
    }
  }

  /// Get products by category
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category,
  ) async {
    try {
      if (category == 'All') {
        return await getProducts();
      }

      final response = await _client
          .from('products')
          .select()
          .eq('category', category)
          .order('id', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      rethrow;
    }
  }

  /// Get products updated since last sync
  /// Note: This returns all products if updated_at column doesn't exist
  Future<List<Map<String, dynamic>>> getProductsSince(DateTime lastSync) async {
    try {
      // Try to get products - if updated_at doesn't exist, just get all
      final response = await _client
          .from('products')
          .select()
          .order('id', ascending: true);

      debugPrint('Fetched ${response.length} products for sync');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting products since: $e');
      rethrow;
    }
  }

  /// Create new product (admin only)
  Future<Map<String, dynamic>> createProduct(Product product) async {
    try {
      debugPrint('🔐 Checking admin permission...');

      // Check admin permission
      if (!await isUserAdmin()) {
        throw Exception('❌ Only admin can create products');
      }

      // Get user ID from Supabase or Laravel auth
      String? userId;
      String? userEmail;

      final supabaseUser = _client.auth.currentUser;
      if (supabaseUser != null) {
        userId = supabaseUser.id;
        userEmail = supabaseUser.email;
      } else if (LaravelAuthService.instance.isAuthenticated) {
        // Use Laravel user ID
        userId = LaravelAuthService.instance.userId?.toString();
        userEmail = LaravelAuthService.instance.currentUser?['email'];
      }

      if (userId == null) {
        throw Exception('❌ User not authenticated');
      }

      debugPrint('✅ Admin verified: $userEmail');
      debugPrint('✅ User ID: $userId');

      // Schema: products.id is int8 (auto-increment), don't set it manually
      // Schema: image_urls is JSONB, so we send as JSON array
      final data = {
        'name': product.name,
        'image_url': product.imageUrl,
        'price': product.price,
        'capacity': product.capacity,
        'rating': product.rating,
        'review_count': product.reviewCount,
        'category': product.category,
        'specifications': product.specifications,
        'description': product.description,
        'image_urls': product.imageUrls,
        'is_active': true,
      };

      debugPrint('📤 Data to insert:');
      debugPrint('   - name: ${data['name']}');
      debugPrint('   - price: ${data['price']}');
      debugPrint('   - category: ${data['category']}');
      debugPrint('   - capacity: ${data['capacity']}');

      debugPrint('🔄 Executing INSERT query...');

      final response = await _client
          .from('products')
          .insert(data)
          .select()
          .single();

      debugPrint('✅ Product created in Supabase successfully!');
      debugPrint('✅ Response: $response');
      return response;
    } catch (e) {
      debugPrint('❌ Error creating product: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Update product (admin only)
  Future<Map<String, dynamic>> updateProduct(String id, Product product) async {
    try {
      debugPrint('🔐 Checking admin permission for update...');

      // Check admin permission
      if (!await isUserAdmin()) {
        throw Exception('❌ Only admin can update products');
      }

      // Verify authentication (Supabase or Laravel)
      final supabaseUser = _client.auth.currentUser;
      final laravelAuth = LaravelAuthService.instance.isAuthenticated;

      if (supabaseUser == null && !laravelAuth) {
        throw Exception('❌ User not authenticated');
      }

      debugPrint('✅ Admin verified, updating product...');

      // Convert to snake_case for Supabase
      final updates = {
        'name': product.name,
        'image_url': product.imageUrl,
        'price': product.price,
        'capacity': product.capacity,
        'rating': product.rating,
        'review_count': product.reviewCount,
        'category': product.category,
        'specifications': product.specifications,
        'description': product.description,
        'image_urls': product.imageUrls,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('products')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      debugPrint('✅ Product updated in Supabase: $id');
      return response;
    } catch (e) {
      debugPrint('❌ Error updating product: $e');
      rethrow;
    }
  }

  /// Delete product (soft delete - admin only)
  Future<void> deleteProduct(String id) async {
    try {
      debugPrint('🗑️ Soft delete request for product: $id');

      // Check admin permission
      if (!await isUserAdmin()) {
        throw Exception('❌ Only admin can delete products');
      }

      debugPrint('✅ Admin permission verified');
      debugPrint('🔄 Setting is_active = false for product: $id');

      await _client.from('products').update({'is_active': false}).eq('id', id);

      debugPrint('✅ Product soft deleted successfully: $id');
    } catch (e) {
      debugPrint('❌ Error deleting product: $e');
      rethrow;
    }
  }

  // ==================== STORAGE (IMAGE UPLOAD) ====================

  /// Upload product image (admin only)
  Future<String> uploadProductImage(XFile imageFile) async {
    try {
      // Check admin permission
      if (!await isUserAdmin()) {
        throw Exception('Only admin can upload images');
      }

      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'products/$fileName';

      await _client.storage
          .from('product-images')
          .uploadBinary(filePath, bytes);

      // Get public URL
      final imageUrl = _client.storage
          .from('product-images')
          .getPublicUrl(filePath);

      debugPrint('Image uploaded: $imageUrl');
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload multiple product images (admin only)
  Future<List<String>> uploadProductImages(List<XFile> imageFiles) async {
    final List<String> imageUrls = [];

    for (var imageFile in imageFiles) {
      try {
        final url = await uploadProductImage(imageFile);
        imageUrls.add(url);
      } catch (e) {
        debugPrint('Error uploading image ${imageFile.path}: $e');
        // Continue with other images even if one fails
      }
    }

    return imageUrls;
  }

  /// Delete product image (admin only)
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      // Check admin permission
      if (!await isUserAdmin()) {
        throw Exception('Only admin can delete images');
      }

      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('product-images');

      if (bucketIndex == -1) {
        throw Exception('Invalid image URL');
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await _client.storage.from('product-images').remove([filePath]);

      debugPrint('Image deleted: $filePath');
    } catch (e) {
      debugPrint('Error deleting image: $e');
      rethrow;
    }
  }

  // ==================== REALTIME SUBSCRIPTIONS ====================

  /// Subscribe to product changes
  RealtimeChannel subscribeToProducts(
    Function(List<Map<String, dynamic>>) onData,
  ) {
    final channel = _client
        .channel('products-channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) {
            debugPrint('Product change detected: ${payload.eventType}');
            // Fetch updated products
            getProducts().then((products) => onData(products));
          },
        )
        .subscribe();

    return channel;
  }

  /// Unsubscribe from channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}
