import 'package:flutter/material.dart';
import '/core/constants/app_spacing.dart';
import '/core/themes/app_colors.dart';

class ProductCardImplicit extends StatefulWidget {
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

  const ProductCardImplicit({
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
  });

  @override
  State<ProductCardImplicit> createState() => _ProductCardImplicitState();
}

class _ProductCardImplicitState extends State<ProductCardImplicit> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isCompact = Theme.of(context).cardTheme.shape != null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: Card(
          elevation: _isPressed ? 8 : 1,
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: isCompact ? 110 : 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _isPressed
                          ? AppColors.maskGreen.withOpacity(0.15)
                          : AppColors.maskGreen.withOpacity(0.08),
                    ),
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

                  // Badge "New!"
                  if (widget.showNewBadge)
                    Positioned(
                      top: 8,
                      left: 8,
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

                  // Tombol Love
                  if (widget.onHeartPressed != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        splashRadius: 18,
                        onPressed: widget.onHeartPressed,
                        icon: const Icon(Icons.favorite_border),
                        color: Colors.grey[600],
                        iconSize: 18,
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                                    decoration: TextDecoration.lineThrough,
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
                              color: AppColors.featherGreen.withOpacity(0.15),
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
                      if (widget.rating != null || widget.soldCount != null)
                        Row(
                          children: [
                            if (widget.rating != null) ...[
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                widget.rating!.toStringAsFixed(1),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 12),
                              ),
                            ],
                            if (widget.soldCount != null) ...[
                              if (widget.rating != null)
                                const SizedBox(width: 4),
                              Text(
                                '• ${widget.soldCount} Sold',
                                style: Theme.of(context).textTheme.bodySmall
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
  }
}
