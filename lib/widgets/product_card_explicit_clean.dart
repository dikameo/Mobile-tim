import 'package:flutter/material.dart';
import '/core/constants/app_spacing.dart';
import '/core/themes/app_colors.dart';

class ProductCardExplicit extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String price;
  final String? originalPrice;
  final double? discountPercent;
  final double? rating;
  final int? soldCount;
  final bool showNewBadge;
  final Widget? leading;
  final VoidCallback? onHeartPressed;
  final VoidCallback? onTap;
  final double animationValue; // Nilai animasi dari slider

  const ProductCardExplicit({
    super.key,
    required this.title,
    this.subtitle,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.rating,
    this.soldCount,
    this.showNewBadge = false,
    this.leading,
    this.onHeartPressed,
    this.onTap,
    this.animationValue = 0.0,
  });

  @override
  State<ProductCardExplicit> createState() => _ProductCardExplicitState();
}

class _ProductCardExplicitState extends State<ProductCardExplicit>
    with TickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _popAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _popAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _popController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    _popController.forward();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _popController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _popController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompact = Theme.of(context).cardTheme.shape != null;

    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: () => _onTapCancel(),
      child: AnimatedBuilder(
        animation: _popController,
        builder: (context, child) {
          // Menggunakan animationValue dari slider untuk mengontrol berbagai properti
          final sliderScale = 1.0 + (widget.animationValue * 0.1);
          final sliderRotation = widget.animationValue * 0.1;
          final sliderElevation = 1.0 + (widget.animationValue * 10);
          final sliderOpacity = 0.3 + (widget.animationValue * 0.7);

          return Transform.scale(
            scale: _popAnimation.value * sliderScale,
            child: Transform.rotate(
              angle: sliderRotation,
              child: Card(
                elevation: sliderElevation,
                margin: const EdgeInsets.all(4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ==== Gambar Produk ====
                    Stack(
                      children: [
                        Container(
                          height: isCompact ? 110 : 130,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.maskGreen.withOpacity(
                              sliderOpacity,
                            ),
                          ),
                          child: Transform.scale(
                            scale: sliderScale,
                            child: Center(
                              child:
                                  widget.leading ??
                                  Icon(
                                    Icons.local_cafe,
                                    size: isCompact ? 48 : 60,
                                    color: AppColors.featherGreen,
                                  ),
                            ),
                          ),
                        ),

                        // Badge "New!" dengan animasi dari slider
                        if (widget.showNewBadge)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Transform.scale(
                              scale: sliderScale,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.featherGreen,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'New!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Tombol Love
                        if (widget.onHeartPressed != null)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Transform.rotate(
                              angle: sliderRotation * -1,
                              child: IconButton(
                                splashRadius: 18,
                                onPressed: widget.onHeartPressed,
                                icon: const Icon(Icons.favorite_border),
                                color: Colors.grey[600],
                                iconSize: 18,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // ==== Bagian Konten ====
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Judul & Subtitle ---
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],

                            const SizedBox(height: 6),

                            // --- Harga & Diskon ---
                            Row(
                              children: [
                                Text(
                                  widget.price,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.featherGreen,
                                      ),
                                ),
                                if (widget.originalPrice != null &&
                                    widget.discountPercent != null) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.originalPrice!,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ],
                            ),

                            if (widget.discountPercent != null &&
                                widget.discountPercent! > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.featherGreen.withOpacity(
                                      0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${widget.discountPercent!.toStringAsFixed(0)}% OFF',
                                    style: TextStyle(
                                      color: AppColors.featherGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 6),

                            // --- Rating & Terjual ---
                            if (widget.rating != null ||
                                widget.soldCount != null)
                              Row(
                                children: [
                                  if (widget.rating != null) ...[
                                    Transform.rotate(
                                      angle:
                                          widget.animationValue *
                                          6.28, // Full rotation berdasarkan slider
                                      child: const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      widget.rating!.toStringAsFixed(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 12),
                                    ),
                                  ],
                                  if (widget.soldCount != null) ...[
                                    if (widget.rating != null)
                                      const SizedBox(width: 4),
                                    Text(
                                      '• ${widget.soldCount} Sold',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                    ),
                                  ],
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
          );
        },
      ),
    );
  }
}
