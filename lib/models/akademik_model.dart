import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class MataKuliah {
  final String nama, ruang, waktu, hari;
  final Color warna;
  const MataKuliah(this.nama, this.ruang, this.waktu, this.hari, this.warna);
}

class Tugas {
  final String judul, mataKuliah, deadline;
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
  final String mataKuliah, grade;
  final double nilai;
  const Nilai(this.mataKuliah, this.grade, this.nilai);
}

class Pengumuman {
  final String judul, isi, tanggal, dari;
  const Pengumuman(this.judul, this.isi, this.tanggal, this.dari);
}

class AkademikData {
  static final List<MataKuliah> jadwal = [
    MataKuliah(
      'Pemrograman Mobile',
      'Lab Komputer 2',
      '09.00–10:30',
      'Senin',
      Colors.blue,
    ),
    MataKuliah(
      'Basis Data Lanjut',
      'Ruang B.204',
      '11:00–12:30',
      'Senin',
      Colors.green,
    ),
    MataKuliah(
      'Kecerdasan Buatan',
      'Ruang A.101',
      '13:00–15:30',
      'Rabu',
      Colors.orange,
    ),
    MataKuliah(
      'Jaringan Komputer',
      'Ruang C.302',
      '08:00–09:40',
      'Selasa',
      Colors.purple,
    ),
    MataKuliah(
      'Rekayasa Perangkat Lunak',
      'Ruang B.101',
      '10:00–11:40',
      'Kamis',
      Colors.red,
    ),
    MataKuliah(
      'Matematika Diskrit',
      'Ruang A.202',
      '12:00–13:40',
      'Jumat',
      Colors.teal,
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
  static String profileName = 'Ari Rahman';
  static String profileProgramStudi = 'Teknik Informatika';
  static String profileSemester = '4';
  static String profileNim = '202410101';

  static Future<void> loadData() async {
    final loadedTasks = await StorageService.loadTugasList();
    if (loadedTasks != null) {
      tugasList = loadedTasks.map(Tugas.fromJson).toList();
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
