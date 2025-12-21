import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/admin_order.dart';
import 'laravel_auth_service.dart';

/// API Service for User Order operations
class UserOrderService {
  static final UserOrderService _instance = UserOrderService._internal();
  factory UserOrderService() => _instance;
  UserOrderService._internal();

  static get _client => SupabaseConfig.client;

  /// Get current user ID from Laravel or Supabase auth
  String? _getCurrentUserId() {
    // Try Supabase first
    final supabaseUser = SupabaseConfig.currentUser;
    if (supabaseUser != null) return supabaseUser.id;

    // Fallback to Laravel auth
    if (LaravelAuthService.instance.isAuthenticated) {
      return LaravelAuthService.instance.userId?.toString();
    }
    return null;
  }

  /// GET /api/user/orders
  /// Get all orders for current authenticated user
  Future<List<AdminOrder>> getUserOrders() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('orders')
          .select('*')
          .eq('user_id', userId)
          .order('order_date', ascending: false);

      final data = response as List;
      return data.map((json) => AdminOrder.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching user orders: $e');
      rethrow;
    }
  }

  /// GET /api/user/orders/:id
  /// Get single order detail for current user
  Future<AdminOrder> getUserOrder(String orderId) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('orders')
          .select('*')
          .eq('id', orderId)
          .eq('user_id', userId)
          .single();

      return AdminOrder.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error fetching user order: $e');
      rethrow;
    }
  }

  /// Confirm payment and change status to processing
  Future<AdminOrder> confirmPayment(String orderId) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get current order
      final currentOrder = await getUserOrder(orderId);

      // Only allow confirm if pending payment
      if (currentOrder.status != OrderStatus.pendingPayment) {
        throw Exception(
          'Cannot confirm payment for order with status: ${currentOrder.status.displayName}',
        );
      }

      final response = await _client
          .from('orders')
          .update({
            'status': OrderStatus.processing.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId)
          .eq('user_id', userId)
          .select()
          .single();

      return AdminOrder.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error confirming payment: $e');
      rethrow;
    }
  }

  /// Cancel order (only if status is pendingPayment)
  Future<AdminOrder> cancelOrder(String orderId) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get current order
      final currentOrder = await getUserOrder(orderId);

      // Only allow cancel if pending payment
      if (currentOrder.status != OrderStatus.pendingPayment) {
        throw Exception(
          'Cannot cancel order with status: ${currentOrder.status.displayName}',
        );
      }

      final response = await _client
          .from('orders')
          .update({
            'status': OrderStatus.cancelled.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId)
          .eq('user_id', userId)
          .select()
          .single();

      return AdminOrder.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error cancelling order: $e');
      rethrow;
    }
  }
}
