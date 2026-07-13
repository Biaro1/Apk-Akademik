import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/akademik_model.dart';
import '../models/course_model.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  String _searchQuery = '';
  bool _showFavoritesOnly = false;

  List<CourseModel> get _filteredCourses {
    final query = _searchQuery.toLowerCase();
    final filtered = AkademikData.jadwal.where((course) {
      if (_showFavoritesOnly && !course.isFavorite) return false;
      return course.nama.toLowerCase().contains(query) ||
          course.ruang.toLowerCase().contains(query) ||
          course.hari.toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return a.nama.compareTo(b.nama);
    });
    return filtered;
  }

  Future<void> _toggleFavorite(CourseModel course) async {
    setState(() {
      course.isFavorite = !course.isFavorite;
    });
    await AkademikData.saveCourses();
  }

  Future<void> _openNotes(CourseModel course) async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return Padding(              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan untuk ${course.nama}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (course.notes.isNotEmpty)
                    ...course.notes.map((note) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.note,
                              size: 18,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(note, style: TextStyle(color: theme.colorScheme.onSurface))),
                          ],
                        ),
                      );
                    }),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Tambah Catatan',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        setModalState(() {
                          course.notes.add(text);
                          controller.clear();
                        });
                        AkademikData.saveCourses();
                      },
                      child: const Text('Simpan Catatan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    setState(() {});
  }

  Future<void> _exportJadwalPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Jadwal Kuliah',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              ..._filteredCourses.map((course) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(10),
                    ),
                  ),
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        course.nama,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '${course.hari} • ${course.waktu} • ${course.ruang}',
                      ),
                      if (course.notes.isNotEmpty)
                        pw.Text('Catatan: ${course.notes.join('; ')}'),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          'Jadwal Kuliah',
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportJadwalPdf,
            tooltip: 'Export jadwal ke PDF',
          ),
        ],
      ),
      body: Container(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                      hintText: 'Cari mata kuliah, ruang, atau hari',
                      fillColor: theme.colorScheme.surface,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text('Semua', style: TextStyle(color: !_showFavoritesOnly ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface)),
                          selected: !_showFavoritesOnly,
                          onSelected: (value) {
                            setState(() {
                              _showFavoritesOnly = !value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: Text('Favorit', style: TextStyle(color: _showFavoritesOnly ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface)),
                          selected: _showFavoritesOnly,
                          onSelected: (value) {
                            setState(() {
                              _showFavoritesOnly = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                itemCount: _filteredCourses.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final course = _filteredCourses[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: course.warna.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.class_, color: course.warna),
                      ),
                      title: Text(
                        course.nama,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${course.hari} • ${course.waktu}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            course.ruang,
                              style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),                          ),
                          if (course.notes.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${course.notes.length} catatan tersedia',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 92,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                course.isFavorite
                                    ? Icons.star
                                    : Icons.star_border,
                                color: course.isFavorite
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () => _toggleFavorite(course),
                            ),
                            IconButton(
                              icon: const Icon(Icons.note_alt_outlined),
                              onPressed: () => _openNotes(course),
                            ),
                          ],
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
}
