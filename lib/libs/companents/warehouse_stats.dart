import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'warehouse_chart.dart';

class WarehouseStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const WarehouseStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Omborxona Statistikasi",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: defaultPadding),
          WarehouseChart(
            categoryDistribution: stats['category_distribution'],
            totalQuantity: stats['total_quantity'],
          ),
          const SizedBox(height: defaultPadding),
          _buildStatsOverview(),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      children: [
        _buildStatRow(
          icon: Icons.inventory,
          title: "Umumiy miqdor",
          value: "${stats['total_quantity'].toStringAsFixed(1)} dona",
          color: primaryColor,
        ),
        const SizedBox(height: defaultPadding / 2),
        _buildStatRow(
          icon: Icons.attach_money,
          title: "Xarajat qiymati",
          value: "${stats['total_cost_value'].toStringAsFixed(2)} so‘m",
          color: Colors.green,
        ),
        const SizedBox(height: defaultPadding / 2),
        _buildStatRow(
          icon: Icons.sell,
          title: "Sotuv qiymati",
          value: "${stats['total_selling_value'].toStringAsFixed(2)} so‘m",
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}