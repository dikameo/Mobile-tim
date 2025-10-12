import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/utils/screen.dart';
import '/widgets/product_card_implicit.dart';
import 'product_detail.dart';

// Model data kopi
class CoffeeProduct {
  final String name;
  final String description;
  final String price;
  final String? originalPrice;
  final double? discountPercent;
  final double? rating;
  final int? soldCount;
  final bool isNew;
  final IconData icon;

  CoffeeProduct({
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.rating,
    this.soldCount,
    this.isNew = false,
    this.icon = Icons.local_cafe,
  });
}

class CoffeeCatalogWithMediaQuery extends StatefulWidget {
  const CoffeeCatalogWithMediaQuery({super.key});

  @override
  State<CoffeeCatalogWithMediaQuery> createState() =>
      _CoffeeCatalogWithMediaQueryState();
}

class _CoffeeCatalogWithMediaQueryState
    extends State<CoffeeCatalogWithMediaQuery> {
  // State variables untuk kontrol UI
  double _itemSpacing = 16.0;
  double _scaleFactor = 1.0;
  double _animationSpeed = 1.0;

  // Data produk kopi lengkap
  final List<CoffeeProduct> _coffeeItems = [
    CoffeeProduct(
      name: 'Espresso',
      description: 'Strong & bold',
      price: 'Rp25.000',
      originalPrice: 'Rp30.000',
      rating: 4.8,
      soldCount: 120,
      isNew: true,
      icon: Icons.coffee,
    ),
    CoffeeProduct(
      name: 'Cold Brew',
      description: 'Smooth & refreshing',
      price: 'Rp30.000',
      rating: 4.9,
      soldCount: 98,
      icon: Icons.ac_unit,
    ),
    CoffeeProduct(
      name: 'Cappuccino',
      description: 'Espresso with milk foam',
      price: 'Rp28.000',
      originalPrice: 'Rp35.000',
      rating: 4.7,
      soldCount: 85,
      icon: Icons.local_cafe,
    ),
    CoffeeProduct(
      name: 'Latte',
      description: 'Creamy milk coffee',
      price: 'Rp27.000',
      rating: 4.6,
      soldCount: 210,
      isNew: true,
      icon: Icons.emoji_food_beverage,
    ),
    CoffeeProduct(
      name: 'Mocha',
      description: 'Chocolate espresso delight',
      price: 'Rp32.000',
      originalPrice: 'Rp40.000',
      rating: 4.5,
      soldCount: 64,
      icon: Icons.cake,
    ),
    CoffeeProduct(
      name: 'Americano',
      description: 'Espresso with hot water',
      price: 'Rp22.000',
      rating: 4.4,
      soldCount: 150,
      icon: Icons.water_drop,
    ),
    CoffeeProduct(
      name: 'Flat White',
      description: 'Smooth microfoam espresso',
      price: 'Rp29.000',
      originalPrice: 'Rp35.000',
      rating: 4.8,
      soldCount: 72,
      isNew: true,
      icon: Icons.layers,
    ),
    CoffeeProduct(
      name: 'Affogato',
      description: 'Espresso over vanilla ice cream',
      price: 'Rp35.000',
      rating: 4.9,
      soldCount: 45,
      icon: Icons.icecream,
    ),
  ];

  /// Menentukan jumlah kolom grid berdasarkan lebar layar (MediaQuery)
  int _getCrossAxisCount(double width) {
    if (width < 600) return 2; // Mobile
    if (width < 900) return 3; // Tablet Portrait
    return 4; // Tablet Landscape / Desktop
  }

  /// Menghitung ukuran font yang adaptif
  double _getAdaptiveFontSize(double width) {
    if (width < 600) return 13.0;
    if (width < 900) return 14.0;
    return 15.0;
  }

  /// Menghitung ukuran icon yang adaptif
  double _getAdaptiveIconSize(double width) {
    if (width < 600) return 38.0;
    if (width < 900) return 42.0;
    return 48.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog - AnimatedContainer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Get.toNamed('/catalog-layoutbuilder');
            },
            tooltip: 'Ganti ke AnimationController',
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () =>
                Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControlPanel(context),
          _buildBreakpointInfo(context),
          Expanded(child: _buildResponsiveGrid(context)),
        ],
      ),
    );
  }

  /// Widget panel kontrol dengan slider
  Widget _buildControlPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).cardTheme.color?.withOpacity(0.5),
      child: Column(
        children: [
          _buildSliderControl(
            icon: Icons.space_bar_rounded,
            label: 'Jarak Item',
            value: _itemSpacing,
            min: 8.0,
            max: 32.0,
            divisions: 6,
            onChanged: (value) => setState(() => _itemSpacing = value),
          ),
          _buildSliderControl(
            icon: Icons.zoom_in_rounded,
            label: 'Skala Card',
            value: _scaleFactor,
            min: 0.8,
            max: 1.2,
            divisions: 4,
            isPercentage: true,
            onChanged: (value) => setState(() => _scaleFactor = value),
          ),
          _buildSliderControl(
            icon: Icons.speed,
            label: 'Kecepatan Animasi',
            value: _animationSpeed,
            min: 0.5,
            max: 2.0,
            divisions: 6,
            isPercentage: true,
            onChanged: (value) => setState(() => _animationSpeed = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderControl({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    bool isPercentage = false,
  }) {
    final displayValue = isPercentage
        ? '${(value * 100).toStringAsFixed(0)}%'
        : '${value.toStringAsFixed(0)}px';

    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: displayValue,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            displayValue,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// Widget info breakpoint
  Widget _buildBreakpointInfo(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(width);
    String breakpointName = 'Mobile';
    if (width >= 600 && width < 900) breakpointName = 'Tablet';
    if (width >= 900) breakpointName = 'Desktop';

    return Container(
      color: Theme.of(context).cardTheme.color?.withOpacity(0.5),
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Text(
          'MediaQuery • $breakpointName (${width.toInt()}px) • $crossAxisCount Kolom • AnimatedContainer',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// Widget grid responsif
  Widget _buildResponsiveGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(width);

    return GridView.builder(
      padding: EdgeInsets.all(_itemSpacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: _itemSpacing,
        mainAxisSpacing: _itemSpacing,
        childAspectRatio: 0.85,
      ),
      itemCount: _coffeeItems.length,
      itemBuilder: (context, index) {
        return _buildCoffeeCard(
          context: context,
          product: _coffeeItems[index],
          animationSpeed: _animationSpeed,
        );
      },
    );
  }

  /// Widget kartu kopi dengan AnimatedContainer
  Widget _buildCoffeeCard({
    required BuildContext context,
    required CoffeeProduct product,
    required double animationSpeed,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(name: product.name),
          ),
        );
      },
      child: Transform.scale(
        scale: _scaleFactor,
        child: Hero(
          tag: 'coffee_${product.name}',
          child: _AnimatedCoffeeCard(
            product: product,
            animationSpeed: animationSpeed,
            onHeartPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Disukai: ${product.name}'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(name: product.name),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Widget card dengan AnimatedContainer (Pop-up Animation)
class _AnimatedCoffeeCard extends StatefulWidget {
  final CoffeeProduct product;
  final double animationSpeed;
  final VoidCallback? onHeartPressed;
  final VoidCallback? onTap;

  const _AnimatedCoffeeCard({
    required this.product,
    required this.animationSpeed,
    this.onHeartPressed,
    this.onTap,
  });

  @override
  State<_AnimatedCoffeeCard> createState() => _AnimatedCoffeeCardState();
}

class _AnimatedCoffeeCardState extends State<_AnimatedCoffeeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final animationDuration = Duration(
      milliseconds: (150 / widget.animationSpeed).round(),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: AnimatedContainer(
          duration: animationDuration,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.2 : 0.1),
                blurRadius: _isPressed ? 8 : 4,
                offset: Offset(0, _isPressed ? 4 : 2),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.all(4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Section dengan animasi background
                Expanded(
                  flex: 3,
                  child: AnimatedContainer(
                    duration: animationDuration,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _isPressed
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2)
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Center(
                      child: AnimatedScale(
                        duration: animationDuration,
                        scale: _isPressed ? 1.1 : 1.0,
                        child: Icon(
                          widget.product.icon,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),

                // Content Section
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              widget.product.price,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            const Spacer(),
                            if (widget.product.rating != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    widget.product.rating!.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
