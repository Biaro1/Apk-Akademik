import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/akademik_model.dart';

class NilaiPage extends StatelessWidget {
  const NilaiPage({super.key});

  Color _gradeColor(BuildContext context, String grade) {
    final theme = Theme.of(context);
    if (grade.startsWith('A')) return theme.colorScheme.primary;
    if (grade.startsWith('B')) return theme.colorScheme.secondary;
    return theme.colorScheme.tertiary ?? theme.colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ipk =
        AkademikData.nilaiList.map((n) => n.nilai).reduce((a, b) => a + b) /
        AkademikData.nilaiList.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          'Transkrip Nilai',
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Container(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                    _statItem(context, 'IPK', ipk.toStringAsFixed(2)),
                    _statItem(context, 'Mata Kuliah', '${AkademikData.nilaiList.length}'),
                    _statItem(context, 'SKS', '96'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribusi Grade',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 30,
                        sections: AkademikData.nilaiList
                            .fold<Map<String, int>>({}, (map, value) {
                              map[value.grade] = (map[value.grade] ?? 0) + 1;
                              return map;
                            })
                            .entries
                            .map((entry) {
                              final grade = entry.key;
                              final count = entry.value;
                              final color = _gradeColor(context, grade);
                              return PieChartSectionData(
                                value: count.toDouble(),
                                title: grade,
                                radius: 50,
                                color: color,
                                titleStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: AkademikData.nilaiList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final n = AkademikData.nilaiList[i];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        n.mataKuliah,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text('Nilai: ${n.nilai}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _gradeColor(context, n.grade).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          n.grade,
                          style: TextStyle(
                            color: _gradeColor(context, n.grade),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.9), fontSize: 12),
        ),
      ],
    );
  }
}
