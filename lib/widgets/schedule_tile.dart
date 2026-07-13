import 'package:flutter/material.dart';
import '../models/course_model.dart';

class ScheduleTile extends StatelessWidget {
  final CourseModel mk;
  const ScheduleTile(this.mk, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(radius: 5, backgroundColor: mk.warna),
      title: Text(
        mk.nama,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface),
      ),
      subtitle: Text(mk.ruang, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Text(
        mk.waktu,
        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
      ),
      dense: true,
    );
  }
}
