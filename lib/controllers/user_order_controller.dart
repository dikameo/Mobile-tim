import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/admin_order.dart';
import '../services/user_order_service.dart';

class UserOrderController extends GetxController {
  final UserOrderService _service = UserOrderService();

  final orders = <AdminOrder>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      orders.value = await _service.getUserOrders();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load orders: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<AdminOrder?> getOrderDetail(String orderId) async {
    try {
      return await _service.getUserOrder(orderId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load order detail: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Cancel Order'),
          content: const Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
      );

      if (confirm != true) return false;

      isLoading.value = true;
      await _service.cancelOrder(orderId);

      Get.snackbar(
        'Success',
        'Order cancelled successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await loadOrders(showLoading: false);
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel order: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> confirmPayment(String orderId) async {
    try {
      isLoading.value = true;
      await _service.confirmPayment(orderId);

      Get.snackbar(
        'Success',
        'Payment confirmed! Your order is now being processed',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      await loadOrders(showLoading: false);
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to confirm payment: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
