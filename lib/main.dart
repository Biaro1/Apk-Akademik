import 'package:flutter/material.dart';
import 'models/akademik_model.dart';
import 'models/theme_model.dart';
import 'pages/dashboard_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AkademikData.loadData();
  await AuthService.loadAuthState();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: AkademikData.themeSettingsNotifier,
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Dashboard Akademik',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: _buildTheme(settings.primaryColor, Brightness.light),
          darkTheme: _buildTheme(settings.primaryColor, Brightness.dark),
          home: ValueListenableBuilder<bool>(
            valueListenable: AuthService.authNotifier,
            builder: (context, isLoggedIn, _) {
              return isLoggedIn ? const DashboardPage() : const LoginPage();
            },
          ),
        );
      },
    );
  }

  ThemeData _buildTheme(Color color, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: brightness,
    );
    final baseTextTheme = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      primaryColor: color,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      cardColor: colorScheme.surface,
      textTheme: baseTextTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      primaryTextTheme: baseTextTheme.apply(
        bodyColor: colorScheme.onPrimary,
        displayColor: colorScheme.onPrimary,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(
          color: colorScheme.onPrimary,
        ),
        titleTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: color.withOpacity(0.12),
        selectedColor: color,
        disabledColor: color.withOpacity(0.08),
        secondarySelectedColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: TextStyle(
          color: colorScheme.onSurface,
        ),
        brightness: brightness,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.08),
        surfaceTintColor: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      listTileTheme: ListTileThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        iconColor: color,
      ),
    );
  }
}
