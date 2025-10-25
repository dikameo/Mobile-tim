import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../config/theme.dart';
import '../providers/wishlist_provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.white,
        selectedItemColor: AppTheme.secondaryOrange,
        unselectedItemColor: AppTheme.textGray,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: wishlistProvider.itemCount > 0
                ? badges.Badge(
                    badgeContent: Text('${wishlistProvider.itemCount}'),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: AppTheme.secondaryOrange,
                    ),
                    child: const Icon(Icons.favorite_outline),
                  )
                : const Icon(Icons.favorite_outline),
            activeIcon: wishlistProvider.itemCount > 0
                ? badges.Badge(
                    badgeContent: Text('${wishlistProvider.itemCount}'),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: AppTheme.secondaryOrange,
                    ),
                    child: const Icon(Icons.favorite),
                  )
                : const Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
