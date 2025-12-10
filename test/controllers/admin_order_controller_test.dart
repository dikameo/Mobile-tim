import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:roaster_apps/controllers/admin_order_controller.dart';
import 'package:roaster_apps/models/admin_order.dart';

void main() {
  group('AdminOrderController', () {
    late AdminOrderController controller;

    setUp(() {
      controller = AdminOrderController();
    });

    tearDown(() {
      Get.delete<AdminOrderController>();
    });

    test('Initial state should be correct', () {
      expect(controller.orders.isEmpty, true);
      expect(controller.isLoading.value, false);
      expect(controller.currentPage.value, 1);
      expect(controller.selectedStatus.value, null);
    });

    test('Filter by status should update selected status', () {
      controller.filterByStatus(OrderStatus.processing);
      expect(controller.selectedStatus.value, OrderStatus.processing);
      expect(controller.currentPage.value, 1);
    });

    test(
      'Order status transition validation - pendingPayment to processing',
      () {
        const status = OrderStatus.pendingPayment;
        expect(status.canTransitionTo(OrderStatus.processing), true);
        expect(status.canTransitionTo(OrderStatus.shipped), false);
        expect(status.canTransitionTo(OrderStatus.completed), false);
        expect(status.canTransitionTo(OrderStatus.cancelled), true);
      },
    );

    test('Order status transition validation - processing to shipped', () {
      const status = OrderStatus.processing;
      expect(status.canTransitionTo(OrderStatus.shipped), true);
      expect(status.canTransitionTo(OrderStatus.completed), false);
      expect(status.canTransitionTo(OrderStatus.cancelled), true);
    });

    test('Order status transition validation - shipped to completed', () {
      const status = OrderStatus.shipped;
      expect(status.canTransitionTo(OrderStatus.completed), true);
      expect(status.canTransitionTo(OrderStatus.processing), false);
    });

    test('Order status transition validation - completed cannot change', () {
      const status = OrderStatus.completed;
      expect(status.canTransitionTo(OrderStatus.cancelled), false);
      expect(status.canTransitionTo(OrderStatus.processing), false);
    });

    test('Order status transition validation - cancelled cannot change', () {
      const status = OrderStatus.cancelled;
      expect(status.canTransitionTo(OrderStatus.processing), false);
      expect(status.canTransitionTo(OrderStatus.completed), false);
    });

    test('Order status display names are correct', () {
      expect(OrderStatus.pendingPayment.displayName, 'Menunggu Pembayaran');
      expect(OrderStatus.processing.displayName, 'Diproses');
      expect(OrderStatus.shipped.displayName, 'Dikirim');
      expect(OrderStatus.completed.displayName, 'Selesai');
      expect(OrderStatus.cancelled.displayName, 'Dibatalkan');
    });
  });
}
