import 'package:flutter/material.dart';
import 'package:sklad/controllers/get_controller.dart';
import '../constants.dart';
import '../responsive.dart';

/// Ombor statistikasini ko‘rsatuvchi widget
class WarehouseStats extends StatelessWidget {
  final Map<String, dynamic>? stats;

  const WarehouseStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    // Agar stats null yoki bo‘sh bo‘lsa, default qiymatlarni ishlatish
    final effectiveStats = stats ?? {
      'total_products': 0,
      'out_of_stock': 0,
      'debt_sales': 0,
      'discount_sales': 0,
      'debt_with_discount_sales': 0,
      'total_value': 0,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: Responsive.getPadding(
        context,
        basePadding: const EdgeInsets.all(defaultPadding / 2),
      ),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ombor Statistikasi",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: Responsive.getFontSize(context, baseSize: 16),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: defaultPadding / 2),
          _buildHighlightedStatCard(
            context,
            "Umumiy Narx (UZS)",
            "${effectiveStats['total_value'].toString()}",
            Icons.monetization_on,
            Colors.green.shade700,
          ),
          SizedBox(height: defaultPadding / 2),
          _buildStatCard(
            context,
            "Jami Mahsulotlar",
            effectiveStats['total_products'].toString(),
            Icons.inventory,
            Colors.blue.shade600,
          ),
          _buildStatCard(
            context,
            "Tugagan Mahsulotlar",
            effectiveStats['out_of_stock'].toString(),
            Icons.warning,
            Colors.red.shade500,
          ),
          _buildStatCard(
            context,
            "Qarzga Sotuvlar",
            effectiveStats['debt_sales'].toString(),
            Icons.account_balance_wallet,
            Colors.blue.shade600,
          ),
          _buildStatCard(
            context,
            "Chegirmali Sotuvlar",
            effectiveStats['discount_sales'].toString(),
            Icons.discount,
            Colors.blue.shade600,
          ),
          _buildStatCard(
            context,
            "Qarz va Chegirmali",
            effectiveStats['debt_with_discount_sales'].toString(),
            Icons.monetization_on,
            Colors.blue.shade600,
          ),
        ],
      ),
    );
  }

  /// Alohida ajratilgan statistika kartasi (Umumiy Narx uchun)
  Widget _buildHighlightedStatCard(BuildContext context, String title, String value, IconData icon, Color iconColor) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    return GestureDetector(
      onTap: () {}, // Interaktivlik uchun bo‘sh funksiya
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        constraints: BoxConstraints(
          minHeight: Responsive.getFontSize(context, baseSize: isSmallScreen ? 70 : 80),
        ),
        margin: EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
        padding: EdgeInsets.symmetric(
          horizontal: defaultPadding * 1.2,
          vertical: defaultPadding,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade900.withOpacity(0.5),
              Colors.green.shade500.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: iconColor.withOpacity(0.6),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: iconColor,
                      size: Responsive.getFontSize(context, baseSize: 21),
                    ),
                    SizedBox(width: defaultPadding * 0.75),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(context, baseSize: 11),
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: defaultPadding / 6),
                          Text(
                            "Ombordagi barcha mahsulotlar narxi",
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(context, baseSize: 11),
                              color: Colors.white70,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: defaultPadding / 3),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    //value,
                    '${GetController().getMoneyFormat(value)} so‘m',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, baseSize: 10),
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding / 2,
                  vertical: defaultPadding / 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "Muhim",
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, baseSize: 9),
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Oddiy statistika kartasi
  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon, Color iconColor) {
    return GestureDetector(
      onTapDown: (_) {}, // Interaktivlik uchun bo‘sh funksiya
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(vertical: defaultPadding / 4),
        padding: EdgeInsets.symmetric(
          horizontal: defaultPadding / 2,
          vertical: defaultPadding / 3,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              secondaryColor.withOpacity(0.2),
              secondaryColor.withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: iconColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: Responsive.getFontSize(context, baseSize: 20),
            ),
            SizedBox(width: defaultPadding / 3),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, baseSize: 12),
                  color: Colors.white70,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(width: defaultPadding / 3),
            Text(
              value,
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, baseSize: 12),
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}