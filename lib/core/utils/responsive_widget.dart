import 'package:flutter/material.dart';
import 'screen.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final bool useLayoutBuilder; // Jika true, gunakan LayoutBuilder (lokal)

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.useLayoutBuilder = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useLayoutBuilder) {
      // 🔍 Gunakan LayoutBuilder → responsif terhadap ruang PARENT
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          if (maxWidth >= 900) {
            return desktop ?? tablet ?? mobile;
          } else if (maxWidth >= 600) {
            return tablet ?? mobile;
          } else {
            return mobile;
          }
        },
      );
    } else {
      // 🌍 Gunakan MediaQuery → responsif terhadap ukuran LAYAR
      if (Screen.isDesktop(context)) {
        return desktop ?? tablet ?? mobile;
      } else if (Screen.isTablet(context)) {
        return tablet ?? mobile;
      } else {
        return mobile;
      }
    }
  }
}
