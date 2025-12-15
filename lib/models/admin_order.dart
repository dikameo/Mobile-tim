/// Order model matching DB schema exactly
enum OrderStatus {
  pendingPayment,
  processing,
  shipped,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
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

  /// Check if status transition is allowed (for admin, allow all except from completed/cancelled)
  bool canTransitionTo(OrderStatus newStatus) {
    // Don't allow changing from current status to same status
    if (this == newStatus) return false;

    switch (this) {
      case OrderStatus.pendingPayment:
      case OrderStatus.processing:
      case OrderStatus.shipped:
        // Admin can change to any status
        return true;
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        // Cannot change from completed or cancelled
        return false;
    }
  }
}

class AdminOrder {
  final String id;
  final String userId;
  final OrderStatus status;
  final double subtotal;
  final double shippingCost;
  final double total;
  final DateTime orderDate;
  final String shippingAddress;
  final String paymentMethod;
  final String? trackingNumber;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional user info (from join)
  final String? userEmail;
  final String? userName;

  AdminOrder({
    required this.id,
    required this.userId,
    required this.status,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.orderDate,
    required this.shippingAddress,
    required this.paymentMethod,
    this.trackingNumber,
    required this.items,
    this.createdAt,
    this.updatedAt,
    this.userEmail,
    this.userName,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    return AdminOrder(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      status: _parseStatus(json['status']),
      subtotal: _parseDouble(json['subtotal']),
      shippingCost: _parseDouble(json['shipping_cost']),
      total: _parseDouble(json['total']),
      orderDate: DateTime.tryParse(json['order_date'] ?? '') ?? DateTime.now(),
      shippingAddress: json['shipping_address'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      trackingNumber: json['tracking_number'],
      items: _parseItems(json['items']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      userEmail: json['user_email'] ?? json['email'],
      userName: json['user_name'] ?? json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status.name,
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'total': total,
      'order_date': orderDate.toIso8601String(),
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'tracking_number': trackingNumber,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  static OrderStatus _parseStatus(dynamic value) {
    if (value == null) return OrderStatus.pendingPayment;
    final str = value.toString().toLowerCase();
    return OrderStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => OrderStatus.pendingPayment,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static List<OrderItem> _parseItems(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value
        .map(
          (e) => e is Map
              ? OrderItem.fromJson(Map<String, dynamic>.from(e))
              : null,
        )
        .whereType<OrderItem>()
        .toList();
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double priceAtPurchase;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.priceAtPurchase,
  });

  double get totalPrice => priceAtPurchase * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id']?.toString() ?? json['id']?.toString() ?? '',
      productName: json['product_name'] ?? json['name'] ?? '',
      productImage: json['product_image'] ?? json['image_url'],
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      priceAtPurchase: AdminOrder._parseDouble(
        json['price_at_purchase'] ?? json['price'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
    };
  }
}
