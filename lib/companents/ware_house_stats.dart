import 'package:flutter/material.dart';
import '../constants.dart';
import 'custom_loading_widget.dart';

class WarehouseStats extends StatelessWidget {
  final Map<String, dynamic>? stats; // Allow nullable stats

  const WarehouseStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {

    if (stats == null || stats!.isEmpty) {
      return const CustomLoadingWidget();
    }
    // Provide default values if stats is null or incomplete
    final effectiveStats = stats ?? {
      'total_products': 0,
      'out_of_stock': 0,
      'debt_sales': 0,
      'discount_sales': 0,
      'debt_with_discount_sales': 0,
    };

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Ombor Statistikasi", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: defaultPadding),
          _buildStatCard(
            "Jami Mahsulotlar",
            (effectiveStats['total_products'] ?? 0).toString(),
            Icons.inventory,
          ),
          _buildStatCard(
            "Tugagan Mahsulotlar",
            (effectiveStats['out_of_stock'] ?? 0).toString(),
            Icons.warning,
            Colors.red,
          ),
          _buildStatCard(
            "Qarzga Sotuvlar",
            (effectiveStats['debt_sales'] ?? 0).toString(),
            Icons.account_balance_wallet,
          ),
          _buildStatCard(
            "Chegirmali Sotuvlar",
            (effectiveStats['discount_sales'] ?? 0).toString(),
            Icons.discount,
          ),
          _buildStatCard(
            "Qarz va Chegirmali",
            (effectiveStats['debt_with_discount_sales'] ?? 0).toString(),
            Icons.monetization_on,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.white, size: 24),
          const SizedBox(width: defaultPadding),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white))),
          Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}