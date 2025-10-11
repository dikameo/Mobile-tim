import 'package:flutter/material.dart';

class Screen {
  // Dimensi layar penuh (termasuk status bar)
  static Size size(BuildContext context) => MediaQuery.sizeOf(context);

  // Lebar layar
  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  // Tinggi layar
  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  // Padding sistem (notch, status bar, dll)
  static EdgeInsets padding(BuildContext context) =>
      MediaQuery.paddingOf(context);

  // Apakah landscape?
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  // Apakah perangkat mobile?
  static bool isMobile(BuildContext context) => width(context) < 600;

  // Apakah tablet?
  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 900;

  // Apakah desktop/web?
  static bool isDesktop(BuildContext context) => width(context) >= 900;
}
