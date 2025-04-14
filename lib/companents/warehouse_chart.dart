import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

class WarehouseChart extends StatelessWidget {
  final Map<String, double> categoryDistribution;
  final double totalQuantity;

  const WarehouseChart({
    super.key,
    required this.categoryDistribution,
    required this.totalQuantity});

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = _generatePieChartSections();

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              sections: sections,
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: defaultPadding),
                Text(
                  totalQuantity.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 0.5,
                  ),
                ),
                Text("Umumiy miqdor"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections() {
    List<Color> colors = [
      primaryColor,
      Color(0xFF26E5FF),
      Color(0xFFFFCF26),
      Color(0xFFEE2727),
      Colors.green,
      Colors.purple,
    ];
    int colorIndex = 0;

    return categoryDistribution.entries.map((entry) {
      final percentage = (entry.value / totalQuantity) * 100;
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        showTitle: false,
        radius: 25,
      );
    }).toList();
  }
}