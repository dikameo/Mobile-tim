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

  // Dummy data factory
  static List<Order> getDummyOrders() {
    final products = Product.getDummyProducts();
    final now = DateTime.now();

    return [
      Order(
        orderId: 'INV-2025-001234',
        items: [
          OrderItem(
            product: products[0],
            quantity: 1,
            priceAtPurchase: products[0].price,
          ),
        ],
        status: OrderStatus.completed,
        subtotal: products[0].price,
        shippingCost: 250000,
        total: products[0].price + 250000,
        orderDate: now.subtract(const Duration(days: 15)),
        shippingAddress: 'Jl. Kopi Raya No. 123, Jakarta Selatan',
        paymentMethod: 'Virtual Account BCA',
        trackingNumber: 'JNE1234567890',
      ),
      Order(
        orderId: 'INV-2025-001235',
        items: [
          OrderItem(
            product: products[1],
            quantity: 1,
            priceAtPurchase: products[1].price,
          ),
          OrderItem(
            product: products[6],
            quantity: 2,
            priceAtPurchase: products[6].price,
          ),
        ],
        status: OrderStatus.shipped,
        subtotal: products[1].price + (products[6].price * 2),
        shippingCost: 500000,
        total: products[1].price + (products[6].price * 2) + 500000,
        orderDate: now.subtract(const Duration(days: 3)),
        shippingAddress: 'Jl. Roasting Street No. 45, Bandung',
        paymentMethod: 'Credit Card',
        trackingNumber: 'SICEPAT9876543210',
      ),
      Order(
        orderId: 'INV-2025-001236',
        items: [
          OrderItem(
            product: products[3],
            quantity: 1,
            priceAtPurchase: products[3].price,
          ),
        ],
        status: OrderStatus.processing,
        subtotal: products[3].price,
        shippingCost: 200000,
        total: products[3].price + 200000,
        orderDate: now.subtract(const Duration(days: 1)),
        shippingAddress: 'Jl. Espresso No. 78, Surabaya',
        paymentMethod: 'Virtual Account Mandiri',
      ),
      Order(
        orderId: 'INV-2025-001237',
        items: [
          OrderItem(
            product: products[4],
            quantity: 1,
            priceAtPurchase: products[4].price,
          ),
        ],
        status: OrderStatus.pendingPayment,
        subtotal: products[4].price,
        shippingCost: 450000,
        total: products[4].price + 450000,
        orderDate: now.subtract(const Duration(hours: 2)),
        shippingAddress: 'Jl. Barista Avenue No. 12, Yogyakarta',
        paymentMethod: 'Transfer Bank',
      ),
      Order(
        orderId: 'INV-2025-001238',
        items: [
          OrderItem(
            product: products[5],
            quantity: 1,
            priceAtPurchase: products[5].price,
          ),
        ],
        status: OrderStatus.cancelled,
        subtotal: products[5].price,
        shippingCost: 300000,
        total: products[5].price + 300000,
        orderDate: now.subtract(const Duration(days: 7)),
        shippingAddress: 'Jl. Beans Lane No. 99, Semarang',
        paymentMethod: 'Virtual Account BNI',
      ),
    ];
  }
}
