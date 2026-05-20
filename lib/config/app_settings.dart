import 'package:flutter/material.dart';

// --- [State Management] 앱 전역 설정 제어 ---
enum AppMode { login, senior, counselorLogin, counselor }

class AppSettings extends ChangeNotifier {
  AppMode mode = AppMode.login;
  double fontSizeMultiplier = 1.5; // 기본 1.5배 (크게)
  bool isHighContrast = false;
  bool isHapticEnabled = true;

  void setMode(AppMode newMode) {
    mode = newMode;
    notifyListeners();
  }

  void setFontSize(double multiplier) {
    fontSizeMultiplier = multiplier;
    notifyListeners();
  }

  void toggleHighContrast(bool value) {
    isHighContrast = value;
    notifyListeners();
  }

  void toggleHaptic(bool value) {
    isHapticEnabled = value;
    notifyListeners();
  }
}

class SettingsProvider extends InheritedNotifier<AppSettings> {
  const SettingsProvider({
    super.key,
    required AppSettings super.notifier,
    required super.child,
  });

  static AppSettings of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SettingsProvider>()!
        .notifier!;
  }
}
