import 'package:get/get.dart';
import '../models/order.dart';
import '../config/supabase_config.dart';

class OrderController extends GetxController {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  // Load orders from Supabase
  Future<void> loadOrders() async {
    try {
      _isLoading = true;
      update();

      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) {
        print('⚠️ No user logged in, cannot load orders');
        _orders = [];
        _isLoading = false;
        update();
        return;
      }

      final response = await SupabaseConfig.client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _orders = (response as List).map((json) => Order.fromJson(json)).toList();

      print('✅ Loaded ${_orders.length} orders from Supabase');
      _isLoading = false;
      update();
    } catch (e) {
      print('❌ Failed to load orders: $e');
      _orders = [];
      _isLoading = false;
      update();
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
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Insert to Supabase
      await SupabaseConfig.client.from('orders').insert({
        'id': order.orderId,
        'user_id': userId,
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
      update();
      print('✅ Order created successfully');
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
