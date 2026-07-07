import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../models/akademik_model.dart';
import '../widgets/info_card.dart';
import '../widgets/menu_item_widget.dart';
import '../widgets/schedule_tile.dart';
import 'jadwal_page.dart';
import 'nilai_page.dart';
import 'tugas_page.dart';
import 'materi_page.dart';
import 'pengumuman_page.dart';
import 'map_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Uint8List? _profileImageBytes;
  String _profileName = AkademikData.profileName;
  String _profileProgramStudi = AkademikData.profileProgramStudi;
  String _profileSemester = AkademikData.profileSemester;
  String _profileNim = AkademikData.profileNim;

  @override
  void initState() {
    super.initState();
    _profileImageBytes = AkademikData.profileImageBytes;
    _profileName = AkademikData.profileName;
    _profileProgramStudi = AkademikData.profileProgramStudi;
    _profileSemester = AkademikData.profileSemester;
    _profileNim = AkademikData.profileNim;
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      await AkademikData.saveProfileImage(bytes);
      if (!mounted) return;
      setState(() {
        _profileImageBytes = bytes;
      });
    }
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: _profileName);
    final programController = TextEditingController(text: _profileProgramStudi);
    final semesterController = TextEditingController(text: _profileSemester);
    final nimController = TextEditingController(text: _profileNim);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: programController,
                  decoration: const InputDecoration(
                    labelText: 'Program Studi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: semesterController,
                  decoration: const InputDecoration(
                    labelText: 'Semester',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nimController,
                  decoration: const InputDecoration(
                    labelText: 'NIM',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                final messenger = ScaffoldMessenger.of(context);
                // ignore: use_build_context_synchronously
                final navigator = Navigator.of(context);

                AkademikData.saveProfileData(
                  name: nameController.text.trim(),
                  programStudi: programController.text.trim(),
                  semester: semesterController.text.trim(),
                  nim: nimController.text.trim(),
                ).then((_) {
                  if (!mounted) return;
                  setState(() {
                    _profileName = AkademikData.profileName;
                    _profileProgramStudi = AkademikData.profileProgramStudi;
                    _profileSemester = AkademikData.profileSemester;
                    _profileNim = AkademikData.profileNim;
                  });
                  // ignore: use_build_context_synchronously
                  navigator.pop(dialogContext);
                  // ignore: use_build_context_synchronously
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Profil berhasil diperbarui')),
                  );
                });
              },
              child: const Text('Simpan Profil'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showProfileMenu() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blue.shade800,
                      backgroundImage: _profileImageBytes != null
                          ? MemoryImage(_profileImageBytes!)
                          : null,
                      child: _profileImageBytes == null
                          ? const Text(
                              'AR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profil Saya',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_profileName • $_profileProgramStudi',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            'Semester $_profileSemester • NIM $_profileNim',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _profileActionTile(
                  Icons.camera_alt_outlined,
                  'Ubah Foto Profil',
                  () async {
                    Navigator.pop(sheetContext);
                    await _pickImage();
                  },
                ),
                _profileActionTile(
                  Icons.edit_outlined,
                  'Edit Profil',
                  () async {
                    Navigator.pop(sheetContext);
                    await _showEditProfileDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Lihat Detail Profil'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Detail Profil'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nama: $_profileName'),
                              const SizedBox(height: 6),
                              Text('Program Studi: $_profileProgramStudi'),
                              const SizedBox(height: 6),
                              Text('Status: Aktif'),
                              const SizedBox(height: 6),
                              Text('Semester: $_profileSemester'),
                              const SizedBox(height: 6),
                              Text('NIM: $_profileNim'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Tutup'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                _profileActionTile(
                  Icons.delete_outline,
                  'Hapus Foto Profil',
                  () async {
                    Navigator.pop(sheetContext);
                    await AkademikData.saveProfileImage(null);
                    if (!mounted) return;
                    setState(() {
                      _profileImageBytes = null;
                    });
                  },
                ),
              ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistogram() {
    // Count grades
    Map<String, int> gradeCounts = {};
    for (var nilai in AkademikData.nilaiList) {
      gradeCounts[nilai.grade] = (gradeCounts[nilai.grade] ?? 0) + 1;
    }

    // Sort grades for display
    List<String> sortedGrades = gradeCounts.keys.toList()..sort();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: gradeCounts.values.isNotEmpty
            ? gradeCounts.values.reduce((a, b) => a > b ? a : b).toDouble()
            : 0,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < sortedGrades.length) {
                  return Text(
                    sortedGrades[index],
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
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
                color: Colors.blue.shade800,
                width: 20,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _roundedCard({
    required Widget child,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    double radius = 18,
  }) {
    return Card(
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }

  Widget _profileActionTile(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tugasBelumKumpul = AkademikData.tugasList
        .where((t) => !t.sudahDikumpulkan)
        .length;
    final upcomingTasks =
        AkademikData.tugasList.where((t) => !t.sudahDikumpulkan).toList()
          ..sort((a, b) {
            final aDate = a.dueDate ?? DateTime(9999);
            final bDate = b.dueDate ?? DateTime(9999);
            return aDate.compareTo(bDate);
          });
    final nextTask = upcomingTasks.isNotEmpty ? upcomingTasks.first : null;
    final nextClass = AkademikData.jadwal.isNotEmpty ? AkademikData.jadwal.first : null;
    final ipk = AkademikData.nilaiList.isNotEmpty
        ? AkademikData.nilaiList
                .map((n) => n.nilai)
                .reduce((a, b) => a + b) /
            AkademikData.nilaiList.length
        : 0.0;
    final targetIpk = 3.75;
    final ipkProgress = targetIpk > 0
        ? (ipk / targetIpk).clamp(0.0, 1.0)
        : 0.0;

    final menuItems = [
      {
        'icon': Icons.calendar_today,
        'label': 'Jadwal',
        'color': Colors.blue,
        'page': const JadwalPage(),
      },
      {
        'icon': Icons.grade,
        'label': 'Nilai',
        'color': Colors.green,
        'page': const NilaiPage(),
      },
      {
        'icon': Icons.assignment,
        'label': 'Tugas',
        'color': Colors.orange,
        'page': const TugasPage(),
      },
      {
        'icon': Icons.menu_book,
        'label': 'Materi',
        'color': Colors.purple,
        'page': const MateriPage(),
      },
      {
        'icon': Icons.location_on,
        'label': 'Lokasi',
        'color': Colors.teal,
        'page': const MapPage(),
      },
      {
        'icon': Icons.campaign,
        'label': 'Pengumuman',
        'color': Colors.red,
        'page': const PengumumanPage(),
      },
    ];

    final summaryCards = [
      ['IPK', ipk.toStringAsFixed(2), 'Kumulatif', Colors.blue.shade800],
      ['SKS Ditempuh', '96', 'dari 144 SKS', Colors.green.shade800],
      ['Kehadiran', '87%', 'Semester ini', Colors.orange.shade800],
      ['Tugas Aktif', '$tugasBelumKumpul', 'Belum dikumpulkan', Colors.purple.shade800],
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text('Dashboard Akademik'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + kToolbarHeight + 24,
                20,
                36,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF4C8DF5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -40,
                    top: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Halo, selamat belajar!',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _profileName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tetap fokus dan capai target IPK-mu hari ini.',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white24,
                            backgroundImage: _profileImageBytes != null
                                ? MemoryImage(_profileImageBytes!)
                                : null,
                            child: _profileImageBytes == null
                                ? Text(
                                    _profileInitials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildStatusChip('Semester $_profileSemester'),
                          _buildStatusChip('NIM $_profileNim'),
                          _buildStatusChip('Program $_profileProgramStudi'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _roundedCard(
                      margin: EdgeInsets.zero,
                      radius: 24,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Performa Minggu Ini',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'IPK ${ipk.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${(ipkProgress * 100).toStringAsFixed(0)}% dari target ${targetIpk.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.school,
                                color: Colors.blue.shade800,
                                size: 34,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildSectionHeader('Ringkasan Akademik', Icons.school),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: summaryCards.map((data) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: InfoCard(
                            data[0] as String,
                            data[1] as String,
                            data[2] as String,
                            data[3] as Color,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _roundedCard(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Target IPK',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              targetIpk.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LinearProgressIndicator(
                                value: ipkProgress,
                                minHeight: 10,
                                color: Colors.blue.shade800,
                                backgroundColor: Colors.blue.shade100,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(ipkProgress * 100).toStringAsFixed(0)}% tercapai',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _roundedCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tugas Terdekat',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    nextTask?.judul ?? 'Semua tugas selesai',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    nextTask != null
                                        ? '${nextTask.mataKuliah} • ${nextTask.deadline}'
                                        : 'Tidak ada tugas baru',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _roundedCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Kelas Berikutnya',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    nextClass?.nama ?? 'Tidak ada jadwal',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    nextClass != null
                                        ? '${nextClass.hari} • ${nextClass.waktu}'
                                        : 'Tambahkan jadwal baru',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Menu Layanan', Icons.grid_view),
                    SizedBox(
                      height: 116,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(bottom: 4),
                        children: menuItems.map((item) {
                          return MenuItemWidget(
                            icon: item['icon'] as IconData,
                            label: item['label'] as String,
                            color: item['color'] as MaterialColor,
                            onTap: () => _navigate(context, item['page'] as Widget),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Distribusi Nilai', Icons.bar_chart),
                    _roundedCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(height: 200, child: _buildHistogram()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Jadwal Hari Ini', Icons.schedule),
                    _roundedCard(
                      child: Column(
                        children: List.generate(
                          AkademikData.jadwal.take(3).length,
                          (i) {
                            final mk = AkademikData.jadwal[i];
                            return Column(
                              children: [
                                ScheduleTile(mk),
                                if (i < 2) const Divider(height: 1),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Aksi Cepat', Icons.flash_on),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _navigate(context, const TugasPage()),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Kumpulkan Tugas'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF1A73E8)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _navigate(context, const NilaiPage()),
                            icon: const Icon(Icons.bar_chart),
                            label: const Text('Lihat Transkrip'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: Colors.blue.shade700),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey.shade900,
          ),
        ),
      ],
    ),
  );

  String get _profileInitials {
    final parts = _profileName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _profileName.isEmpty
        ? 'AR'
        : _profileName.substring(0, _profileName.length >= 2 ? 2 : _profileName.length).toUpperCase();
  }

  Widget _buildStatusChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.white24,
      side: const BorderSide(color: Colors.white24),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
    );
  }
}
