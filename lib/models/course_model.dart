import 'package:flutter/material.dart';

class CourseModel {
  final String id;
  final String nama;
  final String ruang;
  final String waktu;
  final String hari;
  final int warnaValue;
  bool isFavorite;
  List<String> notes;

  CourseModel({
    required this.id,
    required this.nama,
    required this.ruang,
    required this.waktu,
    required this.hari,
    required this.warnaValue,
    this.isFavorite = false,
    List<String>? notes,
  }) : notes = notes ?? [];

  Color get warna => Color(warnaValue);

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      ruang: json['ruang'] as String,
      waktu: json['waktu'] as String,
      hari: json['hari'] as String,
      warnaValue: json['warna'] as int,
      isFavorite: json['isFavorite'] as bool? ?? false,
      notes:
          (json['notes'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'ruang': ruang,
      'waktu': waktu,
      'hari': hari,
      'warna': warnaValue,
      'isFavorite': isFavorite,
      'notes': notes,
    };
  }
}
