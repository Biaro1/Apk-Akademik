import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/akademik_model.dart';

class HistogramPage extends StatelessWidget {
  const HistogramPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Count grades
    Map<String, int> gradeCounts = {};
    for (var nilai in AkademikData.nilaiList) {
      gradeCounts[nilai.grade] = (gradeCounts[nilai.grade] ?? 0) + 1;
    }

    // Sort grades for display
    List<String> sortedGrades = gradeCounts.keys.toList()..sort();

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text('Histogram Nilai', style: TextStyle(color: theme.colorScheme.onPrimary)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Distribusi Nilai Mata Kuliah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: gradeCounts.values.isNotEmpty ? gradeCounts.values.reduce((a, b) => a > b ? a : b).toDouble() : 0,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < sortedGrades.length) {
                            return Text(sortedGrades[index]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(sortedGrades.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: gradeCounts[sortedGrades[index]]!.toDouble(),
                          color: theme.colorScheme.primary,
                          width: 20,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}