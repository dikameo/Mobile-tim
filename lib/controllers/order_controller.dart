import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../config/supabase_config.dart';
import '../services/laravel_auth_service.dart';
import '../services/notification_trigger_service.dart';

class OrderController extends GetxController {
  final RxList<Order> _orders = <Order>[].obs;
  final RxBool _isLoading = false.obs;
  RealtimeChannel? _ordersSubscription;
  final NotificationTriggerService _notificationService =
      NotificationTriggerService();

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading.value;

  /// Get current user ID from Laravel or Supabase auth
  String? _getCurrentUserId() {
    final supabaseUser = SupabaseConfig.currentUser;
    if (supabaseUser != null) return supabaseUser.id;

    if (LaravelAuthService.instance.isAuthenticated) {
      return LaravelAuthService.instance.userId?.toString();
    }
    return null;
  }

  /// Get user ID as int for database (schema: user_id is bigint)
  int? _getCurrentUserIdAsInt() {
    final userIdStr = _getCurrentUserId();
    if (userIdStr == null) return null;
    return int.tryParse(userIdStr);
  }

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    _setupRealtimeSubscription();
  }

  @override
  void onClose() {
    _ordersSubscription?.unsubscribe();
    super.onClose();
  }

  // Setup real-time subscription untuk auto-update saat admin mengubah status
  void _setupRealtimeSubscription() {
    final userId = _getCurrentUserIdAsInt();
    if (userId == null) return;

    _ordersSubscription = SupabaseConfig.client
        .channel('user_orders_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId, // Now as int
          ),
          callback: (payload) {
            print('🔔 Order updated in real-time: ${payload.newRecord}');
            _handleOrderUpdate(payload.newRecord);
          },
        )
        .subscribe();

    print('✅ Real-time subscription setup for user orders (user_id: $userId)');
  }

  // Handle order update dari real-time subscription
  void _handleOrderUpdate(Map<String, dynamic> updatedData) {
    try {
      final updatedOrder = Order.fromJson(updatedData);
      final index = _orders.indexWhere(
        (o) => o.orderId == updatedOrder.orderId,
      );

      if (index != -1) {
        _orders[index] = updatedOrder;
        print('✅ Order ${updatedOrder.orderId} updated in local list');
      } else {
        // Order baru, tambahkan ke list
        _orders.insert(0, updatedOrder);
        print('✅ New order ${updatedOrder.orderId} added to list');
      }
    } catch (e) {
      print('❌ Failed to handle order update: $e');
    }
  }

  // Load orders from Supabase
  Future<void> loadOrders() async {
    try {
      _isLoading.value = true;

      final userId = _getCurrentUserIdAsInt();
      if (userId == null) {
        print('⚠️ No user logged in, cannot load orders');
        _orders.value = [];
        _isLoading.value = false;
        return;
      }

      print('📦 Loading orders for user ID: $userId');

      final response = await SupabaseConfig.client
          .from('orders')
          .select()
          .eq('user_id', userId) // Now comparing as int
          .order(
            'order_date',
            ascending: false,
          ); // Use order_date instead of created_at

      _orders.value = (response as List)
          .map((json) => Order.fromJson(json))
          .toList();

      print('✅ Loaded ${_orders.length} orders from Supabase');
      _isLoading.value = false;
    } catch (e) {
      print('❌ Failed to load orders: $e');
      _orders.value = [];
      _isLoading.value = false;
    }
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  Future<void> addOrder(Order order) async {
    try {
      final userId = _getCurrentUserIdAsInt();
      if (userId == null) {
        throw Exception('User not logged in or invalid user ID');
      }

      print('📦 Creating order for user ID: $userId');
      print('📦 Order ID: ${order.orderId}');

      // Insert to Supabase (user_id is bigint)
      await SupabaseConfig.client.from('orders').insert({
        'id': order.orderId,
        'user_id': userId, // Now sending as int
        'status': order.status.toString().split('.').last,
        'total': order.total,
        'subtotal': order.subtotal,
        'shipping_cost': order.shippingCost,
        'order_date': order.orderDate.toIso8601String(),
        'shipping_address': order.shippingAddress,
        'payment_method': order.paymentMethod,
        'tracking_number': order.trackingNumber,
        'items': order.items.map((item) => item.toJson()).toList(),
      });

      // Add to local list
      _orders.insert(0, order);
      print('✅ Order created successfully');

      // Trigger notification for new order
      print('🔔 Triggering notification for new order...');
      await _notificationService.afterOrderCreate(order.orderId, userId);
    } catch (e) {
      print('❌ Failed to create order: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      // Update in Supabase
      await SupabaseConfig.client
          .from('orders')
          .update({'status': newStatus.toString().split('.').last})
          .eq('id', orderId);

      // Reload orders
      await loadOrders();
      print('✅ Order status updated successfully');
    } catch (e) {
      print('❌ Failed to update order status: $e');
      rethrow;
    }
  }

  int getOrderCountByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).length;
  }
}
