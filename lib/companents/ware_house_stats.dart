import 'package:flutter/material.dart';
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
          SizedBox(height: defaultPadding / 3),
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

  /// Statistikani ko‘rsatuvchi karta
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color iconColor) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: defaultPadding / 4),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding / 2,
        vertical: defaultPadding / 3,
      ),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: Responsive.getFontSize(context, baseSize: 20),
          ),
          SizedBox(width: defaultPadding / 3),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, baseSize: 12),
                color: Colors.white70,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
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
    );
  }
}