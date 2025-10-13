import 'package:flutter/material.dart';
import '/core/constants/app_spacing.dart';
import '/core/themes/app_colors.dart';

class ProductCard extends StatelessWidget {
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

  const ProductCard({
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
  Widget build(BuildContext context) {
    // Misalnya, kita anggap card ini kompak jika aspect ratio kecil (misalnya < 0.8)
    // Kamu bisa sesuaikan logika ini tergantung childAspectRatio di GridView
    final bool isCompact = Theme.of(context).cardTheme.shape != null;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    color: AppColors.maskGreen.withValues(alpha: 0.08),
                  ),
                  child: Center(
                    child:
                        leading ??
                        Icon(
                          Icons.local_cafe,
                          size: isCompact ? 48 : 60,
                          color: AppColors.featherGreen,
                        ),
                  ),
                ),

                // Badge "New!"
                if (showNewBadge)
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
                if (onHeartPressed != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      splashRadius: 18,
                      onPressed: onHeartPressed,
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
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],

                    const SizedBox(height: 6),

                    // --- Harga & Diskon ---
                    Row(
                      children: [
                        Text(
                          price,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.featherGreen,
                              ),
                        ),
                        if (originalPrice != null &&
                            discountPercent != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            originalPrice!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ],
                    ),

                    if (discountPercent != null && discountPercent! > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.featherGreen.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${discountPercent!.toStringAsFixed(0)}% OFF',
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
                    if (rating != null || soldCount != null)
                      Row(
                        children: [
                          if (rating != null) ...[
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating!.toStringAsFixed(1),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 12),
                            ),
                          ],
                          if (soldCount != null) ...[
                            if (rating != null) const SizedBox(width: 4),
                            Text(
                              '• $soldCount Sold',
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
    );
  }
}
