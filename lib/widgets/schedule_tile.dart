import 'package:flutter/material.dart';
import '../models/akademik_model.dart';

class ScheduleTile extends StatelessWidget {
  final MataKuliah mk;
  const ScheduleTile(this.mk, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(radius: 5, backgroundColor: mk.warna),
      title: Text(mk.nama,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: Text(mk.ruang, style: const TextStyle(fontSize: 11)),
      trailing: Text(mk.waktu,
          style: const TextStyle(fontSize: 11, color: Colors.grey)),
      dense: true,
    );
  }
}