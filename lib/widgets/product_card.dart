import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../config/theme.dart';
import '../controllers/wishlist_controller.dart';
import '../utils/responsive_helper.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool isHorizontal;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Get.find<WishlistController>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (isHorizontal) {
      return _buildHorizontalCard(
        context,
        false, // Placeholder value, isWishlisted is now handled inside Obx
        currencyFormatter,
        wishlistProvider,
      );
    }

    return _buildVerticalCard(
      context,
      false, // Placeholder value, isWishlisted is now handled inside Obx
      currencyFormatter,
      wishlistProvider,
    );
  }

  Widget _buildVerticalCard(
    BuildContext context,
    bool
    _, // Placeholder parameter, not used since isWishlisted is handled in Obx
    NumberFormat currencyFormatter,
    WishlistController wishlistProvider,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    height: context.imageHeight(
                      mobile: 160,
                      tablet: 200,
                      desktop: 240,
                    ),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: context.imageHeight(
                        mobile: 160,
                        tablet: 200,
                        desktop: 240,
                      ),
                      color: theme.colorScheme.surface,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: context.imageHeight(
                        mobile: 160,
                        tablet: 200,
                        desktop: 240,
                      ),
                      color: theme.colorScheme.surface,
                      child: Icon(
                        Icons.coffee,
                        size: context.iconSize(
                          mobile: 48,
                          tablet: 56,
                          desktop: 64,
                        ),
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Wishlist button
                Positioned(
                  top: context.spacing(1),
                  right: context.spacing(1),
                  child: Obx(() {
                    final isWishlisted = wishlistProvider.isInWishlist(
                      product.id,
                    );
                    return GestureDetector(
                      onTap: () => wishlistProvider.toggleWishlist(product),
                      child: Container(
                        padding: EdgeInsets.all(context.spacing(0.75)),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: isWishlisted
                              ? AppTheme.secondaryOrange
                              : theme.iconTheme.color?.withOpacity(0.6),
                          size: context.iconSize(
                            mobile: 18,
                            tablet: 20,
                            desktop: 22,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            // Product details
            Expanded(
              child: Padding(
                padding: context.padding(mobile: 12, tablet: 16, desktop: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Capacity badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing(1),
                        vertical: context.spacing(0.5),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.capacity,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.secondaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: context.fontSize(
                            mobile: 10,
                            tablet: 11,
                            desktop: 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.spacing(0.75)),
                    // Product name
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: context.fontSize(
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: context.iconSize(
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                        ),
                        SizedBox(width: context.spacing(0.5)),
                        Text(
                          '${product.rating}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: context.fontSize(
                                  mobile: 12,
                                  tablet: 13,
                                  desktop: 14,
                                ),
                              ),
                        ),
                        SizedBox(width: context.spacing(0.5)),
                        Text(
                          '(${product.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: context.fontSize(
                                  mobile: 12,
                                  tablet: 13,
                                  desktop: 14,
                                ),
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing(0.75)),
                    // Price
                    Text(
                      currencyFormatter.format(product.price),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.secondaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: context.fontSize(
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                      ),
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

  Widget _buildHorizontalCard(
    BuildContext context,
    bool
    _, // Placeholder parameter, not used since isWishlisted is handled in Obx
    NumberFormat currencyFormatter,
    WishlistController wishlistProvider,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.cardWidth(mobile: 280, tablet: 320, desktop: 360),
        margin: EdgeInsets.only(right: context.spacing(2)),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    height: context.imageHeight(
                      mobile: 180,
                      tablet: 220,
                      desktop: 260,
                    ),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: context.imageHeight(
                        mobile: 180,
                        tablet: 220,
                        desktop: 260,
                      ),
                      color: theme.colorScheme.surface,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: context.imageHeight(
                        mobile: 180,
                        tablet: 220,
                        desktop: 260,
                      ),
                      color: theme.colorScheme.surface,
                      child: Icon(
                        Icons.coffee,
                        size: context.iconSize(
                          mobile: 48,
                          tablet: 56,
                          desktop: 64,
                        ),
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Wishlist button
                Positioned(
                  top: context.spacing(1),
                  right: context.spacing(1),
                  child: Obx(() {
                    final isWishlisted = wishlistProvider.isInWishlist(
                      product.id,
                    );
                    return GestureDetector(
                      onTap: () => wishlistProvider.toggleWishlist(product),
                      child: Container(
                        padding: EdgeInsets.all(context.spacing(0.75)),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: isWishlisted
                              ? AppTheme.secondaryOrange
                              : theme.iconTheme.color?.withOpacity(0.6),
                          size: context.iconSize(
                            mobile: 18,
                            tablet: 20,
                            desktop: 22,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            // Product details
            Expanded(
              child: Padding(
                padding: context.padding(mobile: 12, tablet: 16, desktop: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Capacity badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing(1),
                        vertical: context.spacing(0.5),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.capacity,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.secondaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: context.fontSize(
                            mobile: 10,
                            tablet: 11,
                            desktop: 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.spacing(0.75)),
                    // Product name
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: context.fontSize(
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: context.iconSize(
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                        ),
                        SizedBox(width: context.spacing(0.5)),
                        Text(
                          '${product.rating}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: context.fontSize(
                                  mobile: 12,
                                  tablet: 13,
                                  desktop: 14,
                                ),
                              ),
                        ),
                        SizedBox(width: context.spacing(0.5)),
                        Text(
                          '(${product.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: context.fontSize(
                                  mobile: 12,
                                  tablet: 13,
                                  desktop: 14,
                                ),
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing(0.75)),
                    // Price
                    Text(
                      currencyFormatter.format(product.price),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.secondaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: context.fontSize(
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                      ),
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
