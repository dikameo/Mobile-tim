import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_order_controller.dart';
import '../../models/admin_order.dart';
import '../../config/theme.dart';
import '../../widgets/admin_widgets.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  late final AdminOrderController controller;
  late final Future<AdminOrder?> orderFuture;

  @override
  void initState() {
    super.initState();
    // Try to find existing controller, otherwise create new one
    if (Get.isRegistered<AdminOrderController>(tag: 'admin_order_list')) {
      controller = Get.find<AdminOrderController>(tag: 'admin_order_list');
    } else {
      controller = Get.put(AdminOrderController(), tag: 'admin_order_detail');
    }
    orderFuture = controller.getOrder(widget.orderId);
  }

  @override
  void dispose() {
    // Only delete if we created it in this screen
    if (Get.isRegistered<AdminOrderController>(tag: 'admin_order_detail')) {
      Get.delete<AdminOrderController>(tag: 'admin_order_detail');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryCharcoal,
        foregroundColor: Colors.white,
        title: const Text('Order Detail'),
      ),
      body: FutureBuilder<AdminOrder?>(
        future: orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AdminLoadingIndicator(
              message: 'Loading order details...',
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return AdminErrorState(
              message: 'Failed to load order details',
              onRetry: () {
                setState(() {
                  orderFuture = controller.getOrder(widget.orderId);
                });
              },
            );
          }

          final order = snapshot.data!;
          final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(order, controller),
                const SizedBox(height: 16),
                _buildCustomerInfo(order, dateFormat),
                const SizedBox(height: 16),
                _buildItemsList(order),
                const SizedBox(height: 16),
                _buildPriceSummary(order),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(AdminOrder order, AdminOrderController controller) {
    return AdminCard(
      child: Column(
        children: [
          AdminStatusBadge(
            label: order.status.displayName,
            color: _getStatusColor(order.status),
            icon: _getStatusIcon(order.status),
          ),
          const SizedBox(height: 12),
          Text(
            'Order #${order.id.substring(0, 8)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showStatusChangeDialog(order, controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryCharcoal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Change Status'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(AdminOrder order, DateFormat dateFormat) {
    return Column(
      children: [
        AdminSectionHeader(title: 'Customer Information'),
        const SizedBox(height: 8),
        AdminCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminInfoRow(
                icon: Icons.person_outline,
                label: 'Name',
                value: order.userName ?? 'N/A',
              ),
              const SizedBox(height: 12),
              AdminInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: order.userEmail ?? 'N/A',
              ),
              const Divider(height: 24),
              AdminInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Shipping Address',
                value: order.shippingAddress,
              ),
              const SizedBox(height: 12),
              AdminInfoRow(
                icon: Icons.payment_outlined,
                label: 'Payment Method',
                value: order.paymentMethod,
              ),
              const SizedBox(height: 12),
              AdminInfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Order Date',
                value: dateFormat.format(order.orderDate),
              ),
              if (order.trackingNumber != null) ...[
                const SizedBox(height: 12),
                AdminInfoRow(
                  icon: Icons.local_shipping_outlined,
                  label: 'Tracking Number',
                  value: order.trackingNumber!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(AdminOrder order) {
    return Column(
      children: [
        AdminSectionHeader(title: 'Order Items'),
        const SizedBox(height: 8),
        AdminCard(
          child: Column(
            children: order.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCharcoal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: AppTheme.primaryCharcoal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${item.priceAtPurchase.toStringAsFixed(0)} x ${item.quantity}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rp ${item.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryCharcoal,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(AdminOrder order) {
    return Column(
      children: [
        AdminSectionHeader(title: 'Price Summary'),
        const SizedBox(height: 8),
        AdminCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal', style: TextStyle(fontSize: 14)),
                  Text(
                    'Rp ${order.subtotal.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Shipping Cost', style: TextStyle(fontSize: 14)),
                  Text(
                    'Rp ${order.shippingCost.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp ${order.total.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryCharcoal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingPayment:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingPayment:
        return Icons.payment_rounded;
      case OrderStatus.processing:
        return Icons.inventory_2_rounded;
      case OrderStatus.shipped:
        return Icons.local_shipping_rounded;
      case OrderStatus.completed:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  void _showStatusChangeDialog(
    AdminOrder order,
    AdminOrderController controller,
  ) {
    final trackingController = TextEditingController(
      text: order.trackingNumber,
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Change Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...OrderStatus.values.map((status) {
              final canTransition = order.status.canTransitionTo(status);
              return RadioListTile<OrderStatus>(
                title: Text(status.displayName),
                subtitle: !canTransition && status == order.status
                    ? const Text(
                        'Current status',
                        style: TextStyle(fontSize: 12),
                      )
                    : null,
                value: status,
                groupValue: order.status,
                onChanged: canTransition
                    ? (newStatus) {
                        Get.back();
                        // Langsung update tanpa validasi tracking number
                        controller.updateOrderStatus(
                          order.id,
                          newStatus!,
                          trackingNumber: order.trackingNumber,
                        );
                      }
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
