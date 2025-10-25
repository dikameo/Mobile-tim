import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedAddress = 'Jl. Kopi Raya No. 123, Jakarta Selatan';
  String _selectedShipping = 'JNE Regular';
  String _selectedPayment = 'Virtual Account BCA';
  bool _isProcessing = false;

  final List<String> _addresses = [
    'Jl. Kopi Raya No. 123, Jakarta Selatan',
    'Jl. Roasting Street No. 45, Bandung',
    'Jl. Espresso No. 78, Surabaya',
  ];

  final List<Map<String, dynamic>> _shippingOptions = [
    {'name': 'JNE Regular', 'cost': 250000, 'eta': '3-5 days'},
    {'name': 'JNE Express', 'cost': 450000, 'eta': '1-2 days'},
    {'name': 'SICEPAT Cargo', 'cost': 350000, 'eta': '2-4 days'},
    {'name': 'AnterAja', 'cost': 300000, 'eta': '2-3 days'},
  ];

  final List<String> _paymentMethods = [
    'Virtual Account BCA',
    'Virtual Account Mandiri',
    'Virtual Account BNI',
    'Credit Card',
    'Debit Card',
    'Cicilan 0% (12 bulan)',
  ];

  Future<void> _processCheckout() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Create order
    final selectedItems = cartProvider.items
        .where((item) => item.isSelected)
        .toList();
    final order = Order(
      orderId: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      items: selectedItems.map((item) {
        return OrderItem(
          product: item.product,
          quantity: item.quantity,
          priceAtPurchase: item.product.price,
        );
      }).toList(),
      status: OrderStatus.pendingPayment,
      subtotal: cartProvider.subtotal,
      shippingCost: cartProvider.shippingCost,
      total: cartProvider.total,
      orderDate: DateTime.now(),
      shippingAddress: _selectedAddress,
      paymentMethod: _selectedPayment,
    );

    orderProvider.addOrder(order);
    cartProvider.clearSelectedItems();

    if (mounted) {
      setState(() => _isProcessing = false);

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppTheme.successGreen,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Order Placed Successfully!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Order ID: ${order.orderId}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Please complete payment within 24 hours',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textGray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close checkout
                Navigator.of(context).pop(); // Close cart
              },
              child: const Text('Back to Home'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close checkout
                Navigator.of(context).pop(); // Close cart
                // Navigate to history (would need to update home screen nav)
              },
              child: const Text('View Order'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shipping Address
                  Container(
                    color: AppTheme.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppTheme.secondaryOrange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Shipping Address',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundOffWhite,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedAddress,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () {
                                  _showAddressDialog();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Shipping Method
                  Container(
                    color: AppTheme.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.local_shipping,
                              color: AppTheme.secondaryOrange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Shipping Method',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._shippingOptions.map((option) {
                          return RadioListTile<String>(
                            value: option['name'],
                            groupValue: _selectedShipping,
                            onChanged: (value) {
                              setState(() => _selectedShipping = value!);
                            },
                            activeColor: AppTheme.secondaryOrange,
                            title: Text(option['name']),
                            subtitle: Text(
                              '${option['eta']} - ${currencyFormatter.format(option['cost'])}',
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Payment Method
                  Container(
                    color: AppTheme.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.payment,
                              color: AppTheme.secondaryOrange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Payment Method',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._paymentMethods.map((method) {
                          return RadioListTile<String>(
                            value: method,
                            groupValue: _selectedPayment,
                            onChanged: (value) {
                              setState(() => _selectedPayment = value!);
                            },
                            activeColor: AppTheme.secondaryOrange,
                            title: Text(method),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Order Summary
                  Container(
                    color: AppTheme.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal (${cartProvider.selectedItemCount} items)',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              currencyFormatter.format(cartProvider.subtotal),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping Cost',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              currencyFormatter.format(
                                cartProvider.shippingCost,
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Payment',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              currencyFormatter.format(cartProvider.total),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppTheme.secondaryOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Pay Now Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processCheckout,
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.white,
                          ),
                        ),
                      )
                    : const Text('Pay Now'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _addresses.map((address) {
            return RadioListTile<String>(
              value: address,
              groupValue: _selectedAddress,
              onChanged: (value) {
                setState(() => _selectedAddress = value!);
                Navigator.pop(context);
              },
              activeColor: AppTheme.secondaryOrange,
              title: Text(address),
            );
          }).toList(),
        ),
      ),
    );
  }
}
