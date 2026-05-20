import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/app_settings.dart';

import 'screens/login/initial_login_screen.dart';
import 'screens/login/counselor_login_screen.dart';
import 'screens/senior/senior_main.dart';
import 'screens/counselor/counselor_main.dart';

void main() {
  runApp(const SeniorCareApp());
}

class SeniorCareApp extends StatefulWidget {
  const SeniorCareApp({super.key});

  @override
  State<SeniorCareApp> createState() => _SeniorCareAppState();
}

class _SeniorCareAppState extends State<SeniorCareApp> {
  final AppSettings _settings = AppSettings();

  @override
  Widget build(BuildContext context) {
    return SettingsProvider(
      notifier: _settings,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) {
          final bool isDark = _settings.isHighContrast;
          final Color primaryColor = isDark
              ? Colors.white
              : const Color(0xFF003366);
          final Color accentColor = const Color.fromARGB(255, 60, 145, 184);
          final Color surfaceColor = isDark ? Colors.black : Colors.white;

          return MaterialApp(
            title: 'Senior Care App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              textTheme:
                  GoogleFonts.publicSansTextTheme(
                    Theme.of(context).textTheme,
                  ).copyWith(
                    bodyMedium: TextStyle(
                      fontSize: 18 * _settings.fontSizeMultiplier,
                      height: 1.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    titleLarge: TextStyle(
                      fontSize: 26 * _settings.fontSizeMultiplier,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                    ),
                  ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: accentColor,
                primary: primaryColor,
                secondary: accentColor,
                onPrimary: Colors.white,
                surface: surfaceColor,
                onSurface: isDark ? Colors.white : primaryColor,
                brightness: isDark ? Brightness.dark : Brightness.light,
              ),
              scaffoldBackgroundColor: surfaceColor,
              appBarTheme: AppBarTheme(
                backgroundColor: surfaceColor,
                foregroundColor: primaryColor,
                elevation: 0,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 2,
                ),
              ),
            ),
            home: const InitialLoginScreen(),
          );
        },
      ),
    );
  }
}
