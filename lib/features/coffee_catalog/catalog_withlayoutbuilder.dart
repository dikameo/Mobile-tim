import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/utils/screen.dart';
import '/widgets/product_card.dart';
import 'product_detail.dart';
import '../../core/utils/responsive_widget.dart'; // Sesuaikan path jika perlu

class CoffeeCatalogWithLayoutBuilder extends StatelessWidget {
  const CoffeeCatalogWithLayoutBuilder({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Kopi (LayoutBuilder)'),
        centerTitle: true,
      ),
      body: ResponsiveLayout(
        useLayoutBuilder: true, // Gunakan LayoutBuilder
        mobile: _buildCoffeeGrid(
          crossAxisCount: 2,
          paddingHorizontal: 12.0,
          childAspectRatio: 0.75,
        ),
        tablet: _buildCoffeeGrid(
          crossAxisCount: 3,
          paddingHorizontal: 24.0,
          childAspectRatio: 0.8,
        ),
        desktop: _buildCoffeeGrid(
          crossAxisCount: 4,
          paddingHorizontal: 24.0,
          childAspectRatio: 0.85,
        ),
      ),
    );
  }

  Widget _buildCoffeeGrid({
    required int crossAxisCount,
    required double paddingHorizontal,
    required double childAspectRatio,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
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
              Get.snackbar('Success', 'Disukai: ${item['name']}');
            },
            onTap: () {
              Get.to(() => ProductDetailPage(name: item['name']));
            },
          );
        },
      ),
    );
  }
}
