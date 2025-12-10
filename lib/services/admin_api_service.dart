import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/admin_product.dart';
import '../models/admin_order.dart';

/// API Service for Admin operations
/// Handles all admin product and order management API calls
class AdminApiService {
  static final AdminApiService _instance = AdminApiService._internal();
  factory AdminApiService() => _instance;
  AdminApiService._internal();

  /// Get Supabase client with auth header
  static get _client => SupabaseConfig.client;

  // ==================== PRODUCT ENDPOINTS ====================

  /// GET /api/admin/products
  /// List products with pagination, search, and filters
  Future<Map<String, dynamic>> getProducts({
    String search = '',
    String category = '',
    bool? isActive,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      var query = _client.from('products').select('*');

      // Search by name
      if (search.isNotEmpty) {
        query = query.ilike('name', '%$search%');
      }

      // Filter by category
      if (category.isNotEmpty && category != 'All') {
        query = query.eq('category', category);
      }

      // Filter by active status
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      // Pagination
      final start = (page - 1) * perPage;
      query = query
          .range(start, start + perPage - 1)
          .order('created_at', ascending: false);

      final response = await query;
      final data = response as List;

      final products = data.map((json) => AdminProduct.fromJson(json)).toList();
      final total = data.length; // Use data length as approximation

      return {
        'data': products,
        'meta': {
          'page': page,
          'per_page': perPage,
          'total': total,
          'total_pages': (total / perPage).ceil(),
        },
      };
    } catch (e) {
      debugPrint('❌ Error fetching products: $e');
      rethrow;
    }
  }

  /// GET /api/admin/products/:id
  /// Get single product by ID
  Future<AdminProduct> getProduct(String id) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', id)
          .single();

      return AdminProduct.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error fetching product: $e');
      rethrow;
    }
  }

  /// POST /api/admin/products
  /// Create new product
  Future<AdminProduct> createProduct(AdminProduct product) async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      final data = product.toJson();
      data['created_by'] = userId;
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('products')
          .insert(data)
          .select()
          .single();

      return AdminProduct.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error creating product: $e');
      rethrow;
    }
  }

  /// PUT /api/admin/products/:id
  /// Update existing product
  Future<AdminProduct> updateProduct(String id, AdminProduct product) async {
    try {
      final data = product.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('products')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return AdminProduct.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error updating product: $e');
      rethrow;
    }
  }

  /// DELETE /api/admin/products/:id
  /// Soft delete product (set is_active = false)
  /// Use permanent=true for hard delete
  Future<bool> deleteProduct(String id, {bool permanent = false}) async {
    try {
      if (permanent) {
        await _client.from('products').delete().eq('id', id);
      } else {
        // Soft delete
        await _client
            .from('products')
            .update({
              'is_active': false,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', id);
      }
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting product: $e');
      rethrow;
    }
  }

  // ==================== ORDER ENDPOINTS ====================

  /// GET /api/admin/orders
  /// List orders with filters and pagination
  Future<Map<String, dynamic>> getOrders({
    OrderStatus? status,
    String search = '',
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // Note: orders.user_id references auth.users(id), not profiles(id)
      // We need to join with profiles using the user_id
      var query = _client.from('orders').select('*');

      // Filter by status
      if (status != null) {
        query = query.eq('status', status.name);
      }

      // Search by order ID or user email
      if (search.isNotEmpty) {
        query = query.or('id.ilike.%$search%,user_id.ilike.%$search%');
      }

      // Pagination
      final start = (page - 1) * perPage;
      query = query
          .range(start, start + perPage - 1)
          .order('order_date', ascending: false);

      final response = await query;
      final data = response as List;

      // Fetch user profiles separately for each order
      final orders = await Future.wait(
        data.map((json) async {
          try {
            // Get user profile data from profiles table
            final profileData = await _client
                .from('profiles')
                .select('email, name')
                .eq('id', json['user_id'])
                .maybeSingle();

            if (profileData != null) {
              json['user_email'] = profileData['email'];
              json['user_name'] = profileData['name'];
            }
          } catch (e) {
            debugPrint(
              '⚠️ Failed to fetch profile for user ${json['user_id']}: $e',
            );
            // Continue without user data
          }
          return AdminOrder.fromJson(json);
        }).toList(),
      );

      final total = data.length;

      return {
        'data': orders,
        'meta': {
          'page': page,
          'per_page': perPage,
          'total': total,
          'total_pages': (total / perPage).ceil(),
        },
      };
    } catch (e) {
      debugPrint('❌ Error fetching orders: $e');
      rethrow;
    }
  }

  /// GET /api/admin/orders/:id
  /// Get single order with full details
  Future<AdminOrder> getOrder(String id) async {
    try {
      final response = await _client
          .from('orders')
          .select('*')
          .eq('id', id)
          .single();

      // Fetch user profile data separately
      try {
        final profileData = await _client
            .from('profiles')
            .select('email, name')
            .eq('id', response['user_id'])
            .maybeSingle();

        if (profileData != null) {
          response['user_email'] = profileData['email'];
          response['user_name'] = profileData['name'];
        }
      } catch (e) {
        debugPrint('⚠️ Failed to fetch profile for order $id: $e');
        // Continue without user data
      }

      return AdminOrder.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error fetching order: $e');
      rethrow;
    }
  }

  /// POST /api/admin/orders/:id/status
  /// Change order status with validation
  Future<AdminOrder> updateOrderStatus(
    String id,
    OrderStatus newStatus, {
    String? trackingNumber,
  }) async {
    try {
      // Get current order to validate transition
      final currentOrder = await getOrder(id);

      // Validate status transition
      if (!currentOrder.status.canTransitionTo(newStatus)) {
        throw Exception(
          'Cannot change status from ${currentOrder.status.displayName} to ${newStatus.displayName}',
        );
      }

      // Prepare update data
      final data = <String, dynamic>{
        'status': newStatus.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add tracking number if provided (required for shipped status)
      if (trackingNumber != null && trackingNumber.isNotEmpty) {
        data['tracking_number'] = trackingNumber;
      } else if (newStatus == OrderStatus.shipped) {
        throw Exception(
          'Tracking number is required when changing status to shipped',
        );
      }

      final response = await _client
          .from('orders')
          .update(data)
          .eq('id', id)
          .select('*, profiles!orders_user_id_fkey(email, name)')
          .single();

      // Merge profile data
      if (response['profiles'] != null && response['profiles'] is Map) {
        response['user_email'] = response['profiles']['email'];
        response['user_name'] = response['profiles']['name'];
      }

      return AdminOrder.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error updating order status: $e');
      rethrow;
    }
  }

  /// Export orders to CSV format
  /// Returns CSV string that can be saved to file
  Future<String> exportOrdersCSV({
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('orders')
          .select('*, profiles!orders_user_id_fkey(email, name)');

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (startDate != null) {
        query = query.gte('order_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('order_date', endDate.toIso8601String());
      }

      final response = await query;
      final orders = (response as List).map((json) {
        if (json['profiles'] != null && json['profiles'] is Map) {
          json['user_email'] = json['profiles']['email'];
          json['user_name'] = json['profiles']['name'];
        }
        return AdminOrder.fromJson(json);
      }).toList();

      // Generate CSV
      final buffer = StringBuffer();
      buffer.writeln(
        'Order ID,User Email,Status,Subtotal,Shipping,Total,Order Date,Payment Method,Tracking Number',
      );

      for (final order in orders) {
        buffer.writeln(
          '${order.id},${order.userEmail ?? ""},${order.status.displayName},'
          '${order.subtotal},${order.shippingCost},${order.total},'
          '${order.orderDate.toIso8601String()},${order.paymentMethod},'
          '${order.trackingNumber ?? ""}',
        );
      }

      return buffer.toString();
    } catch (e) {
      debugPrint('❌ Error exporting orders: $e');
      rethrow;
    }
  }
}
