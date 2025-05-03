import 'package:flutter/material.dart';
import '../constants.dart';
import '../responsive.dart';


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

    return Container(
      padding: Responsive.getPadding(context),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ombor Statistikasi",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: Responsive.getFontSize(context, baseSize: 18),
            ),
          ),
          SizedBox(height: defaultPadding / 2),
          _buildStatCard(
            context,
            "Jami Mahsulotlar",
            effectiveStats['total_products'].toString(),
            Icons.inventory,
          ),
          _buildStatCard(
            context,
            "Tugagan Mahsulotlar",
            effectiveStats['out_of_stock'].toString(),
            Icons.warning,
            Colors.red,
          ),
          _buildStatCard(
            context,
            "Qarzga Sotuvlar",
            effectiveStats['debt_sales'].toString(),
            Icons.account_balance_wallet,
          ),
          _buildStatCard(
            context,
            "Chegirmali Sotuvlar",
            effectiveStats['discount_sales'].toString(),
            Icons.discount,
          ),
          _buildStatCard(
            context,
            "Qarz va Chegirmali",
            effectiveStats['debt_with_discount_sales'].toString(),
            Icons.monetization_on,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, [Color? color]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: defaultPadding / 2),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.white, size: Responsive.getFontSize(context, baseSize: 24)),
          SizedBox(width: defaultPadding / 2),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, baseSize: 14),
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, baseSize: 14),
              color: color ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}