import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_order_controller.dart';
import '../../models/admin_order.dart';
import 'package:intl/intl.dart';

class UserOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const UserOrderDetailScreen({super.key, required this.orderId});

  @override
  State<UserOrderDetailScreen> createState() => _UserOrderDetailScreenState();
}

class _UserOrderDetailScreenState extends State<UserOrderDetailScreen> {
  late final UserOrderController controller;
  late final Future<AdminOrder?> orderFuture;

  @override
  void initState() {
    super.initState();
    // Try to find existing controller, otherwise create new one
    if (Get.isRegistered<UserOrderController>(tag: 'user_order_history')) {
      controller = Get.find<UserOrderController>(tag: 'user_order_history');
    } else {
      controller = Get.put(UserOrderController(), tag: 'user_order_detail');
    }
    orderFuture = controller.getOrderDetail(widget.orderId);
  }

  @override
  void dispose() {
    // Only delete if we created it in this screen
    if (Get.isRegistered<UserOrderController>(tag: 'user_order_detail')) {
      Get.delete<UserOrderController>(tag: 'user_order_detail');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                orderFuture = controller.getOrderDetail(widget.orderId);
              });
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<AdminOrder?>(
        future: orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load order'),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final order = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                orderFuture = controller.getOrderDetail(widget.orderId);
              });
              await orderFuture;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusSection(order),
                  const SizedBox(height: 16),
                  _buildOrderInfo(order),
                  const SizedBox(height: 16),
                  _buildItemsList(order),
                  const SizedBox(height: 16),
                  _buildPriceSummary(order),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusSection(AdminOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              order.status.displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Order #${order.id}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (order.trackingNumber != null) ...[
              const SizedBox(height: 8),
              Text(
                'Tracking: ${order.trackingNumber}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
            // Payment button if pending
            if (order.status == OrderStatus.pendingPayment) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handlePayment(order.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay Now'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment(String orderId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Payment'),
        content: const Text(
          'This will simulate payment completion. In production, this would integrate with a payment gateway.\n\nProceed to confirm payment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await controller.confirmPayment(orderId);
      if (success) {
        // Refresh the screen
        setState(() {
          orderFuture = controller.getOrderDetail(orderId);
        });
      }
    }
  }

  Widget _buildOrderInfo(AdminOrder order) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            _infoRow('Order Date', dateFormat.format(order.orderDate)),
            _infoRow('Payment Method', order.paymentMethod),
            _infoRow('Shipping Address', order.shippingAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(AdminOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    if (item.productImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.productImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image),
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Qty: ${item.quantity}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(AdminOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _priceRow('Subtotal', order.subtotal),
            _priceRow('Shipping', order.shippingCost),
            const Divider(),
            _priceRow('Total', order.total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            'Rp ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
