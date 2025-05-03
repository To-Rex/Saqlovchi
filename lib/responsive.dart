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
      MediaQuery.of(context).size.width < 700; // Kichik ekranlar uchun chegarani ko‘tardik

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 700 && MediaQuery.of(context).size.width < 1100; // Planshet chegarasi toraytirildi

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100; // Desktop chegarasi kengaytirildi

  // Dinamik font o‘lchami hisoblash
  static double getFontSize(BuildContext context, {double baseSize = 16}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 700) return baseSize * 0.8; // Mobil uchun kichikroq font
    if (width < 1100) return baseSize * 0.9; // Planshet uchun o‘rta font
    return baseSize; // Desktop uchun asosiy font
  }

  // Dinamik padding hisoblash
  static EdgeInsets getPadding(BuildContext context, {EdgeInsets basePadding = const EdgeInsets.all(16)}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 700) return basePadding * 0.7; // Mobil uchun kichikroq padding
    if (width < 1100) return basePadding * 0.85; // Planshet uchun o‘rta padding
    return basePadding; // Desktop uchun asosiy padding
  }

  // Maksimal kenglik chegarasi
  static double getMaxWidth(BuildContext context, {double maxWidth = 1800}) {
    final width = MediaQuery.of(context).size.width;
    return width > maxWidth ? maxWidth : width * 0.9; // Ultra-keng ekranlar uchun cheklov
  }

  // Grid ustunlar sonini hisoblash
  static int getCrossAxisCount(BuildContext context, {int baseCount = 4}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 700) return 2; // Mobil uchun 2 ustun
    if (width < 1100) return 3; // Planshet uchun 3 ustun
    return baseCount; // Desktop uchun 4 ustun
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Desktop
    if (size.width >= 1100) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: getMaxWidth(context)),
          child: desktop,
        ),
      );
    }
    // Planshet
    else if (size.width >= 700 && tablet != null) {
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