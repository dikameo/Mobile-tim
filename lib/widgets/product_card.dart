import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../config/theme.dart';
import '../providers/wishlist_provider.dart';

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
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isWishlisted = wishlistProvider.isInWishlist(product.id);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (isHorizontal) {
      return _buildHorizontalCard(
        context,
        isWishlisted,
        currencyFormatter,
        wishlistProvider,
      );
    }

    return _buildVerticalCard(
      context,
      isWishlisted,
      currencyFormatter,
      wishlistProvider,
    );
  }

  Widget _buildVerticalCard(
    BuildContext context,
    bool isWishlisted,
    NumberFormat currencyFormatter,
    WishlistProvider wishlistProvider,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGray),
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
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 160,
                      color: AppTheme.backgroundOffWhite,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 160,
                      color: AppTheme.backgroundOffWhite,
                      child: const Icon(
                        Icons.coffee,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Wishlist button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => wishlistProvider.toggleWishlist(product),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_outline,
                        color: isWishlisted
                            ? AppTheme.secondaryOrange
                            : AppTheme.textGray,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Product details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Capacity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Product name
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Text(
                      currencyFormatter.format(product.price),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.secondaryOrange,
                        fontWeight: FontWeight.bold,
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
    bool isWishlisted,
    NumberFormat currencyFormatter,
    WishlistProvider wishlistProvider,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGray),
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
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: AppTheme.backgroundOffWhite,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: AppTheme.backgroundOffWhite,
                      child: const Icon(
                        Icons.coffee,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Wishlist button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => wishlistProvider.toggleWishlist(product),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_outline,
                        color: isWishlisted
                            ? AppTheme.secondaryOrange
                            : AppTheme.textGray,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Product details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Capacity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Product name
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Text(
                      currencyFormatter.format(product.price),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.secondaryOrange,
                        fontWeight: FontWeight.bold,
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
