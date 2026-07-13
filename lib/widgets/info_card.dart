import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const InfoCard(this.label, this.value, this.sub, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = theme.colorScheme.onSurfaceVariant;
    final valueColor = color;
    final subColor = theme.colorScheme.onSurfaceVariant;
    final backgroundColor = theme.colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.12), backgroundColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: labelColor)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: valueColor,
            )),
        Text(sub, style: TextStyle(fontSize: 11, color: subColor)),
      ]),
    );
  }
}