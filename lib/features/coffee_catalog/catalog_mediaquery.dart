import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/utils/screen.dart';
import '/widgets/product_card.dart';
import 'product_detail.dart';

class CoffeeCatalogWithMediaQuery extends StatelessWidget {
  const CoffeeCatalogWithMediaQuery({super.key});

  static final List<Map<String, dynamic>> _coffeeItems = [
    {
      'name': 'Espresso',
      'description': 'Strong & bold',
      'price': 'Rp25.000',
      'originalPrice': 'Rp30.000',
      'discountPercent': 0.0,
      'rating': 4.8,
      'soldCount': 120,
      'isNew': true,
    },
    {
      'name': 'Cold Brew',
      'description': 'Smooth & refreshing',
      'price': 'Rp30.000',
      'originalPrice': 'Rp30.000',
      'discountPercent': 0.0,
      'rating': 4.9,
      'soldCount': 98,
      'isNew': false,
    },
    {
      'name': 'Cappuccino',
      'description': 'Espresso with milk foam',
      'price': 'Rp28.000',
      'originalPrice': 'Rp35.000',
      'discountPercent': 0.0,
      'rating': 4.7,
      'soldCount': 85,
      'isNew': false,
    },
    {
      'name': 'Latte',
      'description': 'Creamy milk coffee',
      'price': 'Rp27.000',
      'originalPrice': 'Rp27.000',
      'discountPercent': 0.0,
      'rating': 4.6,
      'soldCount': 210,
      'isNew': true,
    },
    {
      'name': 'Mocha',
      'description': 'Chocolate espresso delight',
      'price': 'Rp32.000',
      'originalPrice': 'Rp40.000',
      'discountPercent': 0.0,
      'rating': 4.5,
      'soldCount': 64,
      'isNew': false,
    },
    {
      'name': 'Americano',
      'description': 'Espresso with hot water',
      'price': 'Rp22.000',
      'originalPrice': 'Rp22.000',
      'discountPercent': 0.0,
      'rating': 4.4,
      'soldCount': 150,
      'isNew': false,
    },
    {
      'name': 'Flat White',
      'description': 'Smooth microfoam espresso',
      'price': 'Rp29.000',
      'originalPrice': 'Rp35.000',
      'discountPercent': 0.0,
      'rating': 4.8,
      'soldCount': 72,
      'isNew': true,
    },
    {
      'name': 'Affogato',
      'description': 'Espresso over vanilla ice cream',
      'price': 'Rp35.000',
      'originalPrice': 'Rp35.000',
      'discountPercent': 0.0,
      'rating': 4.9,
      'soldCount': 45,
      'isNew': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = Screen.isDesktop(context);
    final paddingHorizontal = Screen.isMobile(context) ? 12.0 : 24.0;
    final crossAxisCount = Screen.isMobile(context)
        ? 2
        : Screen.isTablet(context)
        ? 3
        : 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Kopi (MediaQuery)'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Get.toNamed('/catalog-layoutbuilder');
            },
            tooltip: 'Ganti ke LayoutBuilder',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
        child: GridView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isDesktop ? 0.85 : 0.75,
          ),
          itemCount: _coffeeItems.length,
          itemBuilder: (context, index) {
            final item = _coffeeItems[index];
            return ProductCard(
              title: item['name'],
              subtitle: item['description'],
              price: item['price'],
              originalPrice: item['originalPrice'],
              discountPercent: item['discountPercent'],
              rating: item['rating'],
              soldCount: item['soldCount'],
              showNewBadge: item['isNew'],
              onHeartPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Disukai: ${item['name']}')),
                );
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(name: item['name']),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
