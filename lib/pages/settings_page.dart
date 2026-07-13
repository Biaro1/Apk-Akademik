import 'package:flutter/material.dart';
import '../models/akademik_model.dart';
import '../models/theme_model.dart';
import '../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ThemeSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = AkademikData.themeSettingsNotifier.value;
  }

  void _updateTheme(bool isDarkMode) async {
    final updated = _settings.copyWith(isDarkMode: isDarkMode);
    await AkademikData.updateThemeSettings(updated);
    if (!mounted) return;
    setState(() {
      _settings = updated;
    });
  }

  void _updateColor(MaterialColor color) async {
    final updated = _settings.copyWith(primaryColorValue: color.toARGB32());
    await AkademikData.updateThemeSettings(updated);
    if (!mounted) return;
    setState(() {
      _settings = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: _settings.primaryColor,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tema Aplikasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _settings.isDarkMode,
                    title: const Text('Dark Mode'),
                    subtitle: const Text(
                      'Simpan preferensi tema secara permanen',
                    ),
                    activeThumbColor: _settings.primaryColor,
                    onChanged: _updateTheme,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Warna Tema Utama',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ThemeSettings.accentColors.map((color) {
                      return ChoiceChip(
                        label: Text(colorToName(color)),
                        selected: _settings.primaryColorValue == color.toARGB32(),
                        selectedColor: color.shade700,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        onSelected: (_) => _updateColor(color),
                        labelStyle: TextStyle(
                          color: _settings.primaryColorValue == color.toARGB32()
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                        avatar: _settings.primaryColorValue == color.toARGB32()
                            ? Icon(Icons.check, size: 18, color: theme.colorScheme.onPrimary)
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: Icon(Icons.palette, color: _settings.primaryColor),
                    title: Text(
                      'Tema custom aktif',
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    subtitle: Text(
                      _settings.isDarkMode
                          ? 'Dark mode, warna primer disimpan'
                          : 'Light mode, warna primer disimpan',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await AuthService.logout();
                        if (!mounted) return;
                        navigator.popUntil((route) => route.isFirst);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String colorToName(MaterialColor color) {
    if (color == Colors.blue) return 'Biru';
    if (color == Colors.green) return 'Hijau';
    if (color == Colors.purple) return 'Ungu';
    if (color == Colors.red) return 'Merah';
    return 'Warna';
  }
}
