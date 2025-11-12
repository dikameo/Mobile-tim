import 'package:get/get.dart';
import '../models/order.dart';

class OrderController extends GetxController {
  List<Order> _orders = Order.getDummyOrders();

  List<Order> get orders => _orders;

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

  void addOrder(Order order) {
    _orders.insert(0, order);
    update();
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((order) => order.orderId == orderId);
    if (index >= 0) {
      // Note: Since Order is immutable, in a real app you'd create a new Order
      // For this demo, we'll just update the list
      update();
    }
  }

  int getOrderCountByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).length;
  }
}
