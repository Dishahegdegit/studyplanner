import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ProgressPieChart extends StatelessWidget {
  final int completed;
  final int pending;

  const ProgressPieChart({
    super.key,
    required this.completed,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 55,

          sectionsSpace: 4,

          sections: [

            PieChartSectionData(
              value: completed.toDouble(),
              color: AppColors.lobsterPink,
              radius: 70,
              title: completed.toString(),
              titleStyle: const TextStyle(
                color: AppColors.linen,
                fontWeight: FontWeight.bold,
              ),
            ),

            PieChartSectionData(
              value: pending.toDouble(),
              color: AppColors.winePlum,
              radius: 70,
              title: pending.toString(),
              titleStyle: const TextStyle(
                color: AppColors.linen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
