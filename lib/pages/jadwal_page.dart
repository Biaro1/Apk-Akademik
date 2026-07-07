import 'package:flutter/material.dart';
import '../models/akademik_model.dart';

class JadwalPage extends StatelessWidget {
  const JadwalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text('Jadwal Kuliah',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFF0F2F5),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: AkademikData.jadwal.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final mk = AkademikData.jadwal[i];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: mk.warna.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.class_, color: mk.warna),
                ),
                title: Text(mk.nama,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(mk.ruang),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(mk.waktu,
                        style: TextStyle(
                            color: mk.warna,
                            fontWeight: FontWeight.w500,
                            fontSize: 12)),
                    const Text('Senin',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}