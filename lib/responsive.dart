/*
import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

// This size work fine on my design, maybe you need some customization depends on your design

  // This isMobile, isTablet, isDesktop help us later
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 850;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    // If our width is more than 1100 then we consider it a desktop
    if (_size.width >= 1100) {
      return desktop;
    }
    // If width it less then 1100 and more then 850 we consider it as tablet
    else if (_size.width >= 850 && tablet != null) {
      return tablet!;
    }
    // Or less then that we called it mobile
    else {
      return mobile;
    }
  }
}
*/


import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // Qurilma turini aniqlash uchun yordamchi metodlar
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600; // Mobil uchun chegarani pasaytirdik

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  // Dinamik font o‘lchami hisoblash
  static double getFontSize(BuildContext context, {double baseSize = 16}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return baseSize * 0.85; // Mobil
    if (width < 1200) return baseSize * 0.95; // Planshet
    return baseSize; // Desktop
  }

  // Dinamik padding hisoblash
  static EdgeInsets getPadding(BuildContext context, {EdgeInsets basePadding = const EdgeInsets.all(16)}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return basePadding * 0.8; // Mobil uchun kichikroq
    if (width < 1200) return basePadding * 0.9; // Planshet
    return basePadding; // Desktop
  }

  // Maksimal kenglik chegarasi
  static double getMaxWidth(BuildContext context, {double maxWidth = 1600}) {
    final width = MediaQuery.of(context).size.width;
    return width > maxWidth ? maxWidth : width;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Desktop
    if (size.width >= 1200) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: getMaxWidth(context)),
          child: desktop,
        ),
      );
    }
    // Planshet
    else if (size.width >= 600 && tablet != null) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: getMaxWidth(context)),
          child: tablet!,
        ),
      );
    }
    // Mobil
    else {
      return mobile;
    }
  }
}