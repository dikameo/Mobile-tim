import 'product.dart';

enum OrderStatus { pendingPayment, processing, shipped, completed, cancelled }

class OrderItem {
  final Product product;
  final int quantity;
  final double priceAtPurchase;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.priceAtPurchase,
  });

  double get totalPrice => priceAtPurchase * quantity;

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'price_at_purchase': priceAtPurchase,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    product: Product.fromJson(json['product']),
    quantity: json['quantity'],
    priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
  );
}

class Order {
  final String orderId;
  final List<OrderItem> items;
  final OrderStatus status;
  final double subtotal;
  final double shippingCost;
  final double total;
  final DateTime orderDate;
  final String shippingAddress;
  final String paymentMethod;
  final String? trackingNumber;

  Order({
    required this.orderId,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.orderDate,
    required this.shippingAddress,
    required this.paymentMethod,
    this.trackingNumber,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pendingPayment:
        return 'Menunggu Pembayaran';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.shipped:
        return 'Dikirim';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': orderId,
    'status': status.toString().split('.').last,
    'subtotal': subtotal,
    'shipping_cost': shippingCost,
    'total': total,
    'order_date': orderDate.toIso8601String(),
    'shipping_address': shippingAddress,
    'payment_method': paymentMethod,
    'tracking_number': trackingNumber,
    'items': items.map((item) => item.toJson()).toList(),
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    orderId: json['id'],
    items: (json['items'] as List)
        .map((item) => OrderItem.fromJson(item))
        .toList(),
    status: OrderStatus.values.firstWhere(
      (e) => e.toString().split('.').last == json['status'],
      orElse: () => OrderStatus.processing,
    ),
    subtotal: (json['subtotal'] as num).toDouble(),
    shippingCost: (json['shipping_cost'] as num).toDouble(),
    total: (json['total'] as num).toDouble(),
    orderDate: DateTime.parse(json['order_date']),
    shippingAddress: json['shipping_address'],
    paymentMethod: json['payment_method'],
    trackingNumber: json['tracking_number'],
  );
}
