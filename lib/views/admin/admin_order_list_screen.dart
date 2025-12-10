import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_order_controller.dart';
import '../../models/admin_order.dart';
import '../../widgets/admin_widgets.dart';
import '../../config/theme.dart';
import 'package:intl/intl.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  late final AdminOrderController controller;

  @override
  void initState() {
    super.initState();
    // Use Get.put with tag to avoid conflicts
    controller = Get.put(AdminOrderController(), tag: 'admin_order_list');
    controller.loadOrders();
  }

  @override
  void dispose() {
    Get.delete<AdminOrderController>(tag: 'admin_order_list');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController(
      text: controller.searchQuery.value,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: AppTheme.primaryCharcoal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: controller.exportOrders,
            tooltip: 'Export CSV',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadOrders(refresh: true),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          AdminSearchBar(
            hint: 'Search by Order ID or Email...',
            controller: searchController,
            onChanged: (value) => controller.searchOrders(value),
            onClear: () {
              searchController.clear();
              controller.searchOrders('');
            },
          ),

          // Status Filter Chips
          Obx(
            () => AdminFilterChipBar(
              filters: [
                AdminFilterChipData(
                  label: 'All',
                  selected: controller.selectedStatus.value == null,
                  onSelected: (_) => controller.filterByStatus(null),
                  icon: Icons.all_inclusive,
                ),
                ...OrderStatus.values.map(
                  (status) => AdminFilterChipData(
                    label: status.displayName,
                    selected: controller.selectedStatus.value == status,
                    onSelected: (_) => controller.filterByStatus(status),
                    icon: _getStatusIcon(status),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Orders List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.orders.isEmpty) {
                return const AdminLoadingIndicator(
                  message: 'Loading orders...',
                );
              }

              if (controller.orders.isEmpty) {
                return AdminEmptyState(
                  message: 'No orders found',
                  subtitle: controller.searchQuery.value.isNotEmpty
                      ? 'Try adjusting your search'
                      : 'Orders will appear here once customers place them',
                  icon: Icons.shopping_bag_outlined,
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadOrders(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: controller.orders.length,
                  itemBuilder: (context, index) =>
                      _buildOrderCard(controller.orders[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
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

  Widget _buildOrderCard(AdminOrder order) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    return AdminCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Get.toNamed('/admin/orders/${order.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              AdminStatusBadge(
                label: order.status.displayName,
                color: _getStatusColor(order.status),
                icon: _getStatusIcon(order.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AdminInfoRow(
            icon: Icons.person_outline,
            label: 'Customer',
            value: order.userEmail ?? 'No email',
          ),
          const SizedBox(height: 8),
          AdminInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: dateFormat.format(order.orderDate),
          ),
          const SizedBox(height: 8),
          AdminInfoRow(
            icon: Icons.shopping_bag_outlined,
            label: 'Items',
            value: '${order.items.length} items',
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                'Rp ${order.total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryCharcoal,
                ),
              ),
            ],
          ),
        ],
      ),
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
}
