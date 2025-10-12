import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_detail.dart';

// Model data kopi (sama seperti MediaQuery)
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

class CoffeeCatalogWithLayoutBuilder extends StatefulWidget {
  const CoffeeCatalogWithLayoutBuilder({super.key});

  @override
  State<CoffeeCatalogWithLayoutBuilder> createState() =>
      _CoffeeCatalogWithLayoutBuilderState();
}

class _CoffeeCatalogWithLayoutBuilderState
    extends State<CoffeeCatalogWithLayoutBuilder> {
  // State variables untuk kontrol UI
  double _itemSpacing = 16.0;
  double _scaleFactor = 1.0;

  // Data produk kopi lengkap (sama seperti MediaQuery)
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

  /// Menentukan jumlah kolom grid berdasarkan LayoutBuilder
  int _getCrossAxisCount(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    if (width < 600) return 2; // Mobile
    if (width < 900) return 3; // Tablet Portrait
    return 4; // Tablet Landscape / Desktop
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog - AnimationController'),
        centerTitle: true,
        actions: [
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

  /// Widget panel kontrol dengan slider untuk AnimationController
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
            min: 4.0,
            max: 48.0,
            divisions: 11,
            onChanged: (value) => setState(() => _itemSpacing = value),
          ),
          _buildSliderControl(
            icon: Icons.zoom_in_rounded,
            label: 'Skala Card',
            value: _scaleFactor,
            min: 0.7,
            max: 1.3,
            divisions: 6,
            isPercentage: true,
            onChanged: (value) => setState(() => _scaleFactor = value),
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
        : '${value.toStringAsFixed(1)}px';

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

  /// Widget info breakpoint menggunakan LayoutBuilder
  Widget _buildBreakpointInfo(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = _getCrossAxisCount(constraints);
        String breakpointName = 'Mobile';
        if (width >= 600 && width < 900) breakpointName = 'Tablet';
        if (width >= 900) breakpointName = 'Desktop';

        return Container(
          color: Theme.of(context).cardTheme.color?.withOpacity(0.5),
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              'LayoutBuilder • $breakpointName (${width.toInt()}px) • $crossAxisCount Kolom • AnimationController',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Widget grid responsif menggunakan LayoutBuilder
  Widget _buildResponsiveGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints);

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
            );
          },
        );
      },
    );
  }

  /// Widget kartu kopi dengan AnimationController
  Widget _buildCoffeeCard({
    required BuildContext context,
    required CoffeeProduct product,
  }) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailPage(name: product.name));
      },
      child: Transform.scale(
        scale: _scaleFactor,
        child: Hero(
          tag: 'coffee_${product.name}',
          child: _AnimationControllerCoffeeCard(
            product: product,
            onHeartPressed: () {
              Get.snackbar(
                'Success',
                'Disukai: ${product.name}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withOpacity(0.8),
                colorText: Colors.white,
                borderRadius: 8,
                margin: const EdgeInsets.all(16),
              );
            },
            onTap: () {
              Get.to(
                () => ProductDetailPage(name: product.name),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 300),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Widget card dengan AnimationController (Rotation + Scale Animation)
class _AnimationControllerCoffeeCard extends StatefulWidget {
  final CoffeeProduct product;
  final VoidCallback? onHeartPressed;
  final VoidCallback? onTap;

  const _AnimationControllerCoffeeCard({
    required this.product,
    this.onHeartPressed,
    this.onTap,
  });

  @override
  State<_AnimationControllerCoffeeCard> createState() =>
      _AnimationControllerCoffeeCardState();
}

class _AnimationControllerCoffeeCardState
    extends State<_AnimationControllerCoffeeCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // Fixed duration
      vsync: this,
    );
    _setupBasicAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupThemeAnimations();
  }

  void _setupBasicAnimations() {
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05, // Fixed rotation intensity
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _setupThemeAnimations() {
    _colorAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      end: Theme.of(context).colorScheme.primary.withOpacity(0.3),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _controller.forward();
  }

  void _onTapUp() {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: () => _onTapCancel(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.1 + (_controller.value * 0.1),
                      ),
                      blurRadius: 4 + (_controller.value * 8),
                      offset: Offset(0, 2 + (_controller.value * 4)),
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
                      // Icon Section dengan animasi warna dan scale
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _colorAnimation.value,
                          ),
                          child: Center(
                            child: Transform.scale(
                              scale: 1.0 + (_controller.value * 0.2),
                              child: Transform.rotate(
                                angle:
                                    _controller.value *
                                    6.28 *
                                    1.0, // Fixed rotation intensity
                                child: Icon(
                                  widget.product.icon,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Content Section
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
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
                                        Transform.rotate(
                                          angle:
                                              _controller.value *
                                              6.28, // Star rotation
                                          child: const Icon(
                                            Icons.star,
                                            size: 12,
                                            color: Colors.amber,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          widget.product.rating!
                                              .toStringAsFixed(1),
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
        },
      ),
    );
  }
}
