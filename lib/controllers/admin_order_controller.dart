import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/admin_order.dart';
import '../services/admin_api_service.dart';
import '../services/notification_trigger_service.dart';

class AdminOrderController extends GetxController {
  final AdminApiService _apiService = AdminApiService();

  final orders = <AdminOrder>[].obs;
  final isLoading = false.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final searchQuery = ''.obs;
  final selectedStatus = Rx<OrderStatus?>(null);

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) currentPage.value = 1;

    try {
      isLoading.value = true;
      final result = await _apiService.getOrders(
        status: selectedStatus.value,
        search: searchQuery.value,
        page: currentPage.value,
        perPage: 20,
      );

      orders.value = result['data'] as List<AdminOrder>;
      final meta = result['meta'] as Map<String, dynamic>;
      totalPages.value = meta['total_pages'] ?? 1;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load orders: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchOrders(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    loadOrders();
  }

  void filterByStatus(OrderStatus? status) {
    selectedStatus.value = status;
    currentPage.value = 1;
    loadOrders();
  }

  Future<AdminOrder?> getOrder(String id) async {
    try {
      return await _apiService.getOrder(id);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load order: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<bool> updateOrderStatus(
    String id,
    OrderStatus newStatus, {
    String? trackingNumber,
  }) async {
    try {
      isLoading.value = true;
      await _apiService.updateOrderStatus(
        id,
        newStatus,
        trackingNumber: trackingNumber,
      );

      Get.snackbar(
        'Success',
        'Order status updated',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // 🔔 TRIGGER NOTIFICATION OTOMATIS!
      NotificationTriggerService().afterOrderStatusUpdate(id);

      loadOrders(refresh: true);
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportOrders() async {
    try {
      isLoading.value = true;
      final csv = await _apiService.exportOrdersCSV(
        status: selectedStatus.value,
      );

      // TODO: Save to file using file_picker or share package
      Get.snackbar(
        'Export Ready',
        'CSV data ready to save',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      debugPrint(csv); // For now, print to console
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      loadOrders();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadOrders();
    }
  }
}
