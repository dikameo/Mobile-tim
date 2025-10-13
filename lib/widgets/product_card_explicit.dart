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
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isPlaying = false;
  bool _isRepeating = false;

  final Duration _currentDuration = const Duration(milliseconds: 800);
  final Curve _currentCurve = Curves.bounceInOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _currentDuration, vsync: this);

    _setupAnimations();

    // Status listener untuk tracking state
    _controller.addStatusListener((status) {
      setState(() {
        _isPlaying =
            status == AnimationStatus.forward ||
            status == AnimationStatus.reverse;
      });
    });
  }

  void _setupAnimations() {
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: _currentCurve));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.02,
    ).animate(CurvedAnimation(parent: _controller, curve: _currentCurve));

    _colorAnimation = ColorTween(
      begin: AppColors.maskGreen.withValues(alpha: 0.08),
      end: AppColors.maskGreen.withValues(alpha: 0.15),
    ).animate(CurvedAnimation(parent: _controller, curve: _currentCurve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Manual control methods
  void _startAnimation() {
    setState(() {
      _isPlaying = true;
    });
    _controller.forward();
  }

  void _stopAnimation() {
    setState(() {
      _isPlaying = false;
      _isRepeating = false;
    });
    _controller.stop();
  }

  void _repeatAnimation() {
    setState(() {
      _isRepeating = !_isRepeating;
    });

    if (_isRepeating) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  void _resetAnimation() {
    setState(() {
      _isPlaying = false;
      _isRepeating = false;
    });
    _controller.reset();
  }

  void _onTapDown() {
    if (!_isRepeating) {
      _controller.forward();
    }
  }

  void _onTapUp() {
    if (!_isRepeating) {
      _controller.reverse();
    }
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (!_isRepeating) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompact = Theme.of(context).cardTheme.shape != null;

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
              child: Card(
                elevation: 1 + (_controller.value * 7), // 1 to 8
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
                            color: _colorAnimation.value,
                          ),
                          child: Transform.scale(
                            scale:
                                1.0 + (_controller.value * 0.1), // 1.0 to 1.1
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

                        // Badge "New!" dengan bounce animation
                        if (widget.showNewBadge)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Transform.scale(
                              scale:
                                  1.0 +
                                  (_controller.value * 0.2), // Bounce effect
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
                              angle:
                                  _rotationAnimation.value *
                                  -1, // Counter rotation
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
                                    color: AppColors.featherGreen.withValues(
                                      alpha: 0.15,
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
                                          _controller.value *
                                          6.28, // Full rotation
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

                    // === Simple Control Panel ===
                    Container(
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: _isPlaying
                                ? _stopAnimation
                                : _startAnimation,
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 12,
                              color: _isPlaying ? Colors.red : Colors.green,
                            ),
                          ),
                          GestureDetector(
                            onTap: _repeatAnimation,
                            child: Icon(
                              Icons.repeat,
                              size: 12,
                              color: _isRepeating ? Colors.orange : Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: _resetAnimation,
                            child: const Icon(
                              Icons.refresh,
                              size: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ],
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
