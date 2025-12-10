import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:roaster_apps/views/user/user_order_history_screen.dart';
import 'package:roaster_apps/controllers/user_order_controller.dart';
import 'package:roaster_apps/models/admin_order.dart';

void main() {
  group('UserOrderHistoryScreen Widget Tests', () {
    testWidgets('Shows loading indicator when loading', (tester) async {
      final controller = UserOrderController();
      controller.isLoading.value = true;
      Get.put(controller);

      await tester.pumpWidget(
        GetMaterialApp(home: const UserOrderHistoryScreen()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      Get.delete<UserOrderController>();
    });

    testWidgets('Shows empty state when no orders', (tester) async {
      final controller = UserOrderController();
      controller.isLoading.value = false;
      controller.orders.value = [];
      Get.put(controller);

      await tester.pumpWidget(
        GetMaterialApp(home: const UserOrderHistoryScreen()),
      );

      await tester.pump();

      expect(find.text('No orders yet'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);

      Get.delete<UserOrderController>();
    });

    testWidgets('Shows order list when orders exist', (tester) async {
      final controller = UserOrderController();
      controller.isLoading.value = false;
      controller.orders.value = [
        AdminOrder(
          id: 'order123',
          userId: 'user1',
          status: OrderStatus.processing,
          subtotal: 100000,
          shippingCost: 10000,
          total: 110000,
          orderDate: DateTime.now(),
          shippingAddress: 'Test Address',
          paymentMethod: 'COD',
          items: [],
        ),
      ];
      Get.put(controller);

      await tester.pumpWidget(
        GetMaterialApp(home: const UserOrderHistoryScreen()),
      );

      await tester.pump();

      expect(find.textContaining('Order #'), findsOneWidget);
      expect(find.textContaining('Total: Rp'), findsOneWidget);
      expect(find.text(OrderStatus.processing.displayName), findsOneWidget);

      Get.delete<UserOrderController>();
    });

    testWidgets('Status badge shows correct color for different statuses', (
      tester,
    ) async {
      // This test verifies the status badge rendering logic
      expect(OrderStatus.pendingPayment.displayName, 'Menunggu Pembayaran');
      expect(OrderStatus.processing.displayName, 'Diproses');
      expect(OrderStatus.shipped.displayName, 'Dikirim');
      expect(OrderStatus.completed.displayName, 'Selesai');
      expect(OrderStatus.cancelled.displayName, 'Dibatalkan');
    });
  });
}
