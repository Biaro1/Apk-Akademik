import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/course_model.dart';
import '../models/theme_model.dart';
import '../services/storage_service.dart';

class Tugas {
  final String judul;
  final String mataKuliah;
  final String deadline;
  bool sudahDikumpulkan;

  Tugas(
    this.judul,
    this.mataKuliah,
    this.deadline, {
    this.sudahDikumpulkan = false,
  });

  DateTime? get dueDate {
    final parts = deadline.split(' ');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = _monthMap[parts[1].toLowerCase()];
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  int get daysUntilDeadline {
    final due = dueDate;
    if (due == null) return 999;
    return due.difference(DateTime.now()).inDays;
  }

  bool get isUrgent {
    return !sudahDikumpulkan && daysUntilDeadline == 1;
  }

  static const Map<String, int> _monthMap = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'mei': 5,
    'jun': 6,
    'jul': 7,
    'agu': 8,
    'sep': 9,
    'okt': 10,
    'nov': 11,
    'des': 12,
  };

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'mataKuliah': mataKuliah,
      'deadline': deadline,
      'sudahDikumpulkan': sudahDikumpulkan,
    };
  }

  factory Tugas.fromJson(Map<String, dynamic> json) {
    return Tugas(
      json['judul'] as String,
      json['mataKuliah'] as String,
      json['deadline'] as String,
      sudahDikumpulkan: json['sudahDikumpulkan'] as bool? ?? false,
    );
  }
}

class Nilai {
  final String mataKuliah;
  final String grade;
  final double nilai;
  const Nilai(this.mataKuliah, this.grade, this.nilai);
}

class Pengumuman {
  final String judul;
  final String isi;
  final String tanggal;
  final String dari;
  const Pengumuman(this.judul, this.isi, this.tanggal, this.dari);
}

class AkademikData {
  static List<CourseModel> jadwal = [
    CourseModel(
      id: 'mobile',
      nama: 'Pemrograman Mobile',
      ruang: 'Lab Komputer 2',
      waktu: '09.00–10:30',
      hari: 'Senin',
      warnaValue: Colors.blue.toARGB32(),
    ),
    CourseModel(
      id: 'basis_data',
      nama: 'Basis Data Lanjut',
      ruang: 'Ruang B.204',
      waktu: '11:00–12:30',
      hari: 'Senin',
      warnaValue: Colors.green.toARGB32(),
    ),
    CourseModel(
      id: 'ai',
      nama: 'Kecerdasan Buatan',
      ruang: 'Ruang A.101',
      waktu: '13:00–15:30',
      hari: 'Rabu',
      warnaValue: Colors.orange.toARGB32(),
    ),
    CourseModel(
      id: 'jaringan',
      nama: 'Jaringan Komputer',
      ruang: 'Ruang C.302',
      waktu: '08:00–09:40',
      hari: 'Selasa',
      warnaValue: Colors.purple.toARGB32(),
    ),
    CourseModel(
      id: 'rpl',
      nama: 'Rekayasa Perangkat Lunak',
      ruang: 'Ruang B.101',
      waktu: '10:00–11:40',
      hari: 'Kamis',
      warnaValue: Colors.red.toARGB32(),
    ),
    CourseModel(
      id: 'diskrit',
      nama: 'Matematika Diskrit',
      ruang: 'Ruang A.202',
      waktu: '12:00–13:40',
      hari: 'Jumat',
      warnaValue: Colors.teal.toARGB32(),
    ),
  ];

  static List<Tugas> tugasList = [
    Tugas('UAS Flutter - Dashboard App', 'Pemrograman Mobile', '20 Jun 2025'),
    Tugas('Laporan ERD Sistem Inventaris', 'Basis Data Lanjut', '18 Jun 2025'),
    Tugas('Implementasi Algoritma A*', 'Kecerdasan Buatan', '22 Jun 2025'),
    Tugas('Analisis Protokol TCP/IP', 'Jaringan Komputer', '15 Jun 2025'),
    Tugas(
      'Dokumen SRS Proyek Akhir',
      'Rekayasa Perangkat Lunak',
      '25 Jun 2025',
    ),
    Tugas(
      'Latihan Soal Matematika Diskrit',
      'Matematika Diskrit',
      '30 Jun 2025',
    ),
  ];

  static const List<Nilai> nilaiList = [
    Nilai('Pemrograman Mobile', 'A', 4.0),
    Nilai('Basis Data Lanjut', 'A', 4.0),
    Nilai('Kecerdasan Buatan', 'B+', 3.3),
    Nilai('Jaringan Komputer', 'A', 4.0),
    Nilai('Rekayasa Perangkat Lunak', 'B+', 3.3),
    Nilai('Matematika Diskrit', 'A-', 3.7),
  ];

  static Uint8List? profileImageBytes;
  static String profileName = '';
  static String profileProgramStudi = '';
  static String profileSemester = '';
  static String profileNim = '';
  static ThemeSettings themeSettings = ThemeSettings(
    isDarkMode: false,
    primaryColorValue: Colors.blue.toARGB32(),
  );
  static final ValueNotifier<ThemeSettings> themeSettingsNotifier =
      ValueNotifier(themeSettings);

  static Future<void> loadData() async {
    final loadedTasks = await StorageService.loadTugasList();
    if (loadedTasks != null) {
      tugasList = loadedTasks.map(Tugas.fromJson).toList();
    }

    final loadedCourses = await StorageService.loadCourseList();
    if (loadedCourses != null) {
      jadwal = loadedCourses.map(CourseModel.fromJson).toList();
    }

    final loadedTheme = await StorageService.loadThemeSettings();
    if (loadedTheme != null) {
      themeSettings = ThemeSettings.fromJson(loadedTheme);
      themeSettingsNotifier.value = themeSettings;
    }

    profileImageBytes = await StorageService.loadProfileImage();

    final profileData = await StorageService.loadProfileData();
    profileName = profileData['name'] ?? profileName;
    profileProgramStudi = profileData['programStudi'] ?? profileProgramStudi;
    profileSemester = profileData['semester'] ?? profileSemester;
    profileNim = profileData['nim'] ?? profileNim;
  }

  static Future<void> saveTasks() async {
    await StorageService.saveTugasList(
      tugasList.map((task) => task.toJson()).toList(),
    );
  }

  static Future<void> saveCourses() async {
    await StorageService.saveCourseList(
      jadwal.map((course) => course.toJson()).toList(),
    );
  }

  static Future<void> updateThemeSettings(ThemeSettings updated) async {
    themeSettings = updated;
    themeSettingsNotifier.value = updated;
    await StorageService.saveThemeSettings(updated.toJson());
  }

  static Future<void> saveProfileImage(Uint8List? bytes) async {
    await StorageService.saveProfileImage(bytes);
    profileImageBytes = bytes;
  }

  static Future<void> saveProfileData({
    required String name,
    required String programStudi,
    required String semester,
    required String nim,
  }) async {
    profileName = name;
    profileProgramStudi = programStudi;
    profileSemester = semester;
    profileNim = nim;

    await StorageService.saveProfileData({
      'name': name,
      'programStudi': programStudi,
      'semester': semester,
      'nim': nim,
    });
  }

  static const List<Pengumuman> pengumumanList = [
    Pengumuman(
      'Jadwal UAS Semester Genap 2024/2025',
      'UAS akan dilaksanakan mulai tanggal 1–10 Juli 2025. Pastikan semua tugas telah dikumpulkan sebelum ujian dimulai. Ruangan ujian akan diumumkan H-3.',
      '10 Jun 2025',
      'Akademik',
    ),
    Pengumuman(
      'Pengumpulan KRS Semester Baru',
      'KRS untuk semester ganjil 2025/2026 dibuka mulai 15 Juni 2025. Konsultasikan pilihan mata kuliah dengan dosen pembimbing akademik masing-masing.',
      '8 Jun 2025',
      'Administrasi',
    ),
    Pengumuman(
      'Workshop Flutter & Firebase',
      'Himpunan mahasiswa mengadakan workshop gratis Flutter & Firebase pada 14 Juni 2025 pukul 09:00 di Aula Gedung B. Daftarkan diri segera!',
      '5 Jun 2025',
      'Kemahasiswaan',
    ),
  ];
}
