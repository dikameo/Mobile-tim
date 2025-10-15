import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../config/theme.dart';

class HeroBanner extends StatefulWidget {
  const HeroBanner({super.key});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  int _currentIndex = 0;

  final List<BannerItem> _banners = [
    BannerItem(
      title: 'New Arrival',
      subtitle: 'ProRoast 1000 Home Edition',
      imageUrl:
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
      color: AppTheme.secondaryOrange,
    ),
    BannerItem(
      title: 'Special Offer',
      subtitle: 'Up to 20% Off Commercial Series',
      imageUrl:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800',
      color: AppTheme.primaryCharcoal,
    ),
    BannerItem(
      title: 'Premium Quality',
      subtitle: 'Industrial Grade Roasters',
      imageUrl:
          'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800',
      color: AppTheme.successGreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: _banners.map((banner) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        banner.color.withOpacity(0.9),
                        banner.color.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: banner.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Background image with overlay
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.3,
                            child: Image.network(
                              banner.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(color: banner.color);
                              },
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                banner.title,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppTheme.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                banner.subtitle,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppTheme.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.white,
                                  foregroundColor: banner.color,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text('Shop Now'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _banners.asMap().entries.map((entry) {
            return Container(
              width: _currentIndex == entry.key ? 20 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentIndex == entry.key
                    ? AppTheme.secondaryOrange
                    : AppTheme.borderGray,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class BannerItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Color color;

  BannerItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.color,
  });
}
