import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
              color: Colors.green,
              radius: 70,
              title: completed.toString(),
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            PieChartSectionData(
              value: pending.toDouble(),
              color: Colors.red,
              radius: 70,
              title: pending.toString(),
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}