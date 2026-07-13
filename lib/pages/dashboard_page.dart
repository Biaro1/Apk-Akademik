import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:typed_data';
import '../models/akademik_model.dart';
import '../services/auth_service.dart';
import '../widgets/info_card.dart';
import '../widgets/menu_item_widget.dart';
import '../widgets/schedule_tile.dart';
import 'jadwal_page.dart';
import 'nilai_page.dart';
import 'tugas_page.dart';
import 'materi_page.dart';
import 'pengumuman_page.dart';
import 'map_page.dart';
import 'settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Uint8List? _profileImageBytes;
  String _profileProgramStudi = AkademikData.profileProgramStudi;
  String _profileSemester = AkademikData.profileSemester;
  String _profileNim = AkademikData.profileNim;

  @override
  void initState() {
    super.initState();
    _profileImageBytes = AkademikData.profileImageBytes;
    _profileProgramStudi = AkademikData.profileProgramStudi;
    _profileSemester = AkademikData.profileSemester;
    _profileNim = AkademikData.profileNim;
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildHistogram(BuildContext context) {
    final theme = Theme.of(context);
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
                color: theme.colorScheme.primary,
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

  @override
  Widget build(BuildContext context) {
    final tugasBelumKumpul = AkademikData.tugasList
        .where((t) => !t.sudahDikumpulkan)
        .length;
    final displayName = AuthService.userName.isNotEmpty
        ? AuthService.userName
        : AkademikData.profileName;
    final greetingName = displayName.isNotEmpty ? displayName : 'Mahasiswa';
    final upcomingTasks =
        AkademikData.tugasList.where((t) => !t.sudahDikumpulkan).toList()
          ..sort((a, b) {
            final aDate = a.dueDate ?? DateTime(9999);
            final bDate = b.dueDate ?? DateTime(9999);
            return aDate.compareTo(bDate);
          });
    final nextTask = upcomingTasks.isNotEmpty ? upcomingTasks.first : null;

    final todayName = _weekdayName(DateTime.now().weekday);
    final todayCourses = AkademikData.jadwal
        .where((course) => course.hari.toLowerCase() == todayName.toLowerCase())
        .toList();
    final favoriteCourses = AkademikData.jadwal
        .where((course) => course.isFavorite)
        .toList();
    final todaysSchedule = todayCourses
      ..sort((a, b) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        return 0;
      });
    final nextClass = todaysSchedule.isNotEmpty
        ? todaysSchedule.first
        : AkademikData.jadwal.isNotEmpty
        ? AkademikData.jadwal.first
        : null;

    final ipk = AkademikData.nilaiList.isNotEmpty
        ? AkademikData.nilaiList.map((n) => n.nilai).reduce((a, b) => a + b) /
              AkademikData.nilaiList.length
        : 0.0;
    final targetIpk = 3.75;
    final ipkProgress = targetIpk > 0 ? (ipk / targetIpk).clamp(0.0, 1.0) : 0.0;

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

    final theme = Theme.of(context);
    final headerColor = theme.colorScheme.primary;
    final headerContrast = theme.colorScheme.primaryContainer;

    final summaryCards = [
      ['IPK', ipk.toStringAsFixed(2), 'Kumulatif', theme.colorScheme.primary],
      ['SKS Ditempuh', '96', 'dari 144 SKS', theme.colorScheme.secondary],
      ['Kehadiran', '87%', 'Semester ini', theme.colorScheme.tertiary ?? theme.colorScheme.primary],
      [
        'Tugas Aktif',
        '$tugasBelumKumpul',
        'Belum dikumpulkan',
        theme.colorScheme.error,
      ],
    ];

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: headerColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        titleTextStyle: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        title: const Text('Dashboard Akademik'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: theme.colorScheme.onPrimary),
            onPressed: () => _navigate(context, const SettingsPage()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                36,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [headerColor, headerContrast],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.18),
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
                        color: theme.colorScheme.onPrimary.withOpacity(0.08),
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
                                Text(
                                  'Halo, $greetingName!',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tetap fokus dan capai target IPK-mu hari ini.',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.95),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.24),
                            backgroundImage: _profileImageBytes != null
                                ? MemoryImage(_profileImageBytes!)
                                : null,
                            child: _profileImageBytes == null
                                ? Text(
                                    _profileInitials(displayName),
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
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
                          _buildStatusChip(
                            context,
                            'Semester ${_profileSemester.isNotEmpty ? _profileSemester : 'Belum diatur'}',
                          ),
                          _buildStatusChip(
                            context,
                            'NIM ${_profileNim.isNotEmpty ? _profileNim : 'Belum diatur'}',
                          ),
                          _buildStatusChip(
                            context,
                            'Program ${_profileProgramStudi.isNotEmpty ? _profileProgramStudi : 'Belum diatur'}',
                          ),
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
                                  Text(
                                    'Performa Minggu Ini',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurfaceVariant,
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
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.28),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.school,
                                color: theme.colorScheme.primary,
                                size: 34,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildSectionHeader(context, 'Ringkasan Akademik', Icons.school),
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
                            Text(
                              'Target IPK',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              targetIpk.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LinearProgressIndicator(
                                value: ipkProgress,
                                minHeight: 10,
                                color: theme.colorScheme.primary,
                                backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(ipkProgress * 100).toStringAsFixed(0)}% tercapai',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
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
                                  Text(
                                    'Tugas Terdekat',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    nextTask?.judul ?? 'Semua tugas selesai',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    nextTask != null
                                        ? '${nextTask.mataKuliah} • ${nextTask.deadline}'
                                        : 'Tidak ada tugas baru',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
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
                                  Text(
                                    'Kelas Berikutnya',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    nextClass?.nama ?? 'Tidak ada jadwal',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    nextClass != null
                                        ? '${nextClass.hari} • ${nextClass.waktu}'
                                        : 'Tambahkan jadwal baru',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
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
                    _buildSectionHeader(context, 'Menu Layanan', Icons.grid_view),
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
                            onTap: () =>
                                _navigate(context, item['page'] as Widget),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader(context, 'Distribusi Nilai', Icons.bar_chart),
                    _roundedCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(height: 200, child: _buildHistogram(context)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (favoriteCourses.isNotEmpty) ...[
                      _buildSectionHeader(context, 'Mata Kuliah Favorit', Icons.star),
                      _roundedCard(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: favoriteCourses.map((course) {
                              return Chip(
                                avatar: CircleAvatar(
                                  backgroundColor: course.warna,
                                  child: Icon(
                                    Icons.star,
                                    size: 16,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                                backgroundColor: course.warna.withValues(alpha: 0.15),
                                label: Text(course.nama),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildSectionHeader(context, 'Jadwal Hari Ini', Icons.schedule),
                    _roundedCard(
                      child: Column(
                        children: todaysSchedule.isNotEmpty
                            ? List.generate(todaysSchedule.length, (i) {
                                final mk = todaysSchedule[i];
                                return Column(
                                  children: [
                                    ScheduleTile(mk),
                                    if (i < todaysSchedule.length - 1)
                                      const Divider(height: 1),
                                  ],
                                );
                              })
                            : [
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text(
                                    'Tidak ada jadwal untuk $todayName. Coba lihat jadwal minggu ini atau tambahkan matkul favorit.',
                                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                ),
                              ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader(context, 'Countdown UTS/UAS', Icons.timer),
                    _roundedCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _countdownText(DateTime(2025, 7, 1), 'UTS'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _countdownText(DateTime(2025, 7, 8), 'UAS'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader(context, 'Aksi Cepat', Icons.flash_on),
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
                            onPressed: () =>
                                _navigate(context, const TugasPage()),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Kumpulkan Tugas'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: theme.colorScheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () =>
                                _navigate(context, const NilaiPage()),
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

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _profileInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (name.trim().isEmpty) {
      return 'US';
    }
    return name.trim().substring(0, name.trim().length >= 2 ? 2 : name.trim().length).toUpperCase();
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
      default:
        return 'Minggu';
    }
  }

  String _countdownText(DateTime date, String label) {
    final days = date.difference(DateTime.now()).inDays;
    if (days < 0) {
      return '$label: sudah berlalu';
    }
    if (days == 0) {
      return '$label: hari ini';
    }
    return '$label: $days hari lagi';
  }

  Widget _buildStatusChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chipBackground = theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.22 : 0.14);
    // Choose text color with explicit contrast decision so it remains readable regardless of theme
    final brightnessOfPrimary = ThemeData.estimateBrightnessForColor(theme.colorScheme.primary);
    final labelColor = brightnessOfPrimary == Brightness.dark
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: labelColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: chipBackground,
      side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.32)),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
    );
  }
}
