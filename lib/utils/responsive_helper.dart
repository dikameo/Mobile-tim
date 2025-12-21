import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Responsive spacing
  static double getSpacing(BuildContext context, {double mobile = 8.0}) {
    if (isDesktop(context)) return mobile * 2;
    if (isTablet(context)) return mobile * 1.5;
    return mobile;
  }

  // Responsive padding
  static EdgeInsets getPadding(
    BuildContext context, {
    double mobile = 16.0,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return EdgeInsets.all(desktop ?? mobile * 2);
    }
    if (isTablet(context)) {
      return EdgeInsets.all(tablet ?? mobile * 1.5);
    }
    return EdgeInsets.all(mobile);
  }

  // Responsive font size
  static double getFontSize(
    BuildContext context, {
    double mobile = 14.0,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? mobile * 1.2;
    if (isTablet(context)) return tablet ?? mobile * 1.1;
    return mobile;
  }

  // Grid cross axis count based on screen size
  static int getGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  // Responsive image height
  static double getImageHeight(
    BuildContext context, {
    double mobile = 160.0,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? mobile * 1.5;
    if (isTablet(context)) return tablet ?? mobile * 1.25;
    return mobile;
  }

  // Responsive card width for horizontal lists
  static double getCardWidth(
    BuildContext context, {
    double mobile = 160.0,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? mobile * 1.5;
    if (isTablet(context)) return tablet ?? mobile * 1.25;
    return mobile;
  }

  // Responsive icon size
  static double getIconSize(
    BuildContext context, {
    double mobile = 24.0,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? mobile * 1.3;
    if (isTablet(context)) return tablet ?? mobile * 1.15;
    return mobile;
  }

  // Container max width (untuk centering content di layar besar)
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1400;
    if (isTablet(context)) return 900;
    return double.infinity;
  }

  // Responsive button height
  static double getButtonHeight(
    BuildContext context, {
    double mobile = 48.0,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? mobile * 1.2;
    if (isTablet(context)) return tablet ?? mobile * 1.1;
    return mobile;
  }

  // Adaptive card elevation
  static double getCardElevation(BuildContext context) {
    if (isDesktop(context)) return 4.0;
    if (isTablet(context)) return 3.0;
    return 2.0;
  }
}

// Extension methods untuk kemudahan penggunaan
extension RoasterAppResponsive on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);

  double get width => ResponsiveHelper.getWidth(this);
  double get height => ResponsiveHelper.getHeight(this);

  double spacing([double mobile = 8.0]) =>
      ResponsiveHelper.getSpacing(this, mobile: mobile);

  EdgeInsets padding({double mobile = 16.0, double? tablet, double? desktop}) =>
      ResponsiveHelper.getPadding(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );

  double fontSize({double mobile = 14.0, double? tablet, double? desktop}) =>
      ResponsiveHelper.getFontSize(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );

  int get gridCrossAxisCount => ResponsiveHelper.getGridCrossAxisCount(this);

  double imageHeight({
    double mobile = 160.0,
    double? tablet,
    double? desktop,
  }) => ResponsiveHelper.getImageHeight(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );

  double cardWidth({double mobile = 160.0, double? tablet, double? desktop}) =>
      ResponsiveHelper.getCardWidth(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );

  double iconSize({double mobile = 24.0, double? tablet, double? desktop}) =>
      ResponsiveHelper.getIconSize(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );

  double get maxContentWidth => ResponsiveHelper.getMaxContentWidth(this);

  double buttonHeight({
    double mobile = 48.0,
    double? tablet,
    double? desktop,
  }) => ResponsiveHelper.getButtonHeight(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );

  double get cardElevation => ResponsiveHelper.getCardElevation(this);
}
