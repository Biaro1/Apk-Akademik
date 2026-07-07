import 'package:flutter/material.dart';

class MateriPage extends StatelessWidget {
  const MateriPage({super.key});

  static const List<Map<String, dynamic>> _materi = [
    {
      'mk': 'Pemrograman Mobile',
      'topik': 'Widget & State Management',
      'file': 'pertemuan_11.pdf',
      'size': '2.4 MB',
      'icon': Icons.picture_as_pdf,
      'color': Colors.blue
    },
    {
      'mk': 'Pemrograman Mobile',
      'topik': 'Navigation & Routing',
      'file': 'pertemuan_10.pdf',
      'size': '1.8 MB',
      'icon': Icons.picture_as_pdf,
      'color': Colors.blue
    },
    {
      'mk': 'Basis Data Lanjut',
      'topik': 'Query Optimization',
      'file': 'materi_9.pdf',
      'size': '3.1 MB',
      'icon': Icons.picture_as_pdf,
      'color': Colors.green
    },
    {
      'mk': 'Kecerdasan Buatan',
      'topik': 'Neural Network Dasar',
      'file': 'slide_8.pptx',
      'size': '5.2 MB',
      'icon': Icons.slideshow,
      'color': Colors.orange
    },
    {
      'mk': 'Jaringan Komputer',
      'topik': 'Protokol TCP/IP Layer',
      'file': 'modul_7.pdf',
      'size': '1.5 MB',
      'icon': Icons.picture_as_pdf,
      'color': Colors.purple
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700,
        title: const Text('Materi Kuliah',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFF0F2F5),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _materi.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final m = _materi[i];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (m['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(m['icon'] as IconData,
                      color: m['color'] as Color),
                ),
                title: Text(m['topik'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13)),
                subtitle: Text('${m['mk']} • ${m['size']}',
                    style: const TextStyle(fontSize: 11)),
                trailing: IconButton(
                  icon: const Icon(Icons.download_rounded),
                  color: Colors.grey,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Mengunduh ${m['file']}...')),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}