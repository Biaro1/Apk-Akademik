import 'package:flutter/material.dart';

class ThemeSettings {
  final bool isDarkMode;
  final int primaryColorValue;

  ThemeSettings({required this.isDarkMode, required this.primaryColorValue});

  Color get primaryColor => Color(primaryColorValue);

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeSettings copyWith({bool? isDarkMode, int? primaryColorValue}) {
    return ThemeSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {'isDarkMode': isDarkMode, 'primaryColorValue': primaryColorValue};
  }

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      primaryColorValue: json['primaryColorValue'] as int? ?? Colors.blue.toARGB32(),
    );
  }

  static const List<MaterialColor> accentColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.red,
  ];
}
