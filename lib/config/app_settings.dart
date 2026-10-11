import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppMode { login, senior, counselorLogin, counselor }

class AppSettings extends ChangeNotifier {
  static const _fontSizeKey = 'accessibility.font_size_multiplier';
  static const _darkModeKey = 'accessibility.dark_mode';
  static const _hapticKey = 'accessibility.haptic_enabled';
  static const supportedFontSizes = <double>[0.9, 1.0, 1.2, 1.4];

  AppSettings({SharedPreferences? preferences})
    : _preferences = preferences;

  final SharedPreferences? _preferences;
  SharedPreferences? _loadedPreferences;

  AppMode mode = AppMode.login;
  double fontSizeMultiplier = 0.9;
  bool isDarkMode = false;
  bool isHapticEnabled = true;

  Future<SharedPreferences> get _prefs async =>
      _preferences ?? (_loadedPreferences ??= await SharedPreferences.getInstance());

  Future<void> load() async {
    final preferences = await _prefs;
    final storedFontSize = preferences.getDouble(_fontSizeKey);
    if (storedFontSize != null &&
        supportedFontSizes.contains(storedFontSize)) {
      fontSizeMultiplier = storedFontSize;
    }
    isDarkMode = preferences.getBool(_darkModeKey) ?? false;
    isHapticEnabled = preferences.getBool(_hapticKey) ?? true;
    notifyListeners();
  }

  void setMode(AppMode newMode) {
    mode = newMode;
    notifyListeners();
  }

  Future<void> setFontSize(double multiplier) async {
    if (!supportedFontSizes.contains(multiplier)) {
      throw ArgumentError.value(multiplier, 'multiplier', 'Unsupported size');
    }
    fontSizeMultiplier = multiplier;
    notifyListeners();
    await _save(await _prefs, _fontSizeKey, multiplier);
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    notifyListeners();
    await _save(await _prefs, _darkModeKey, value);
  }

  Future<void> toggleHaptic(bool value) async {
    isHapticEnabled = value;
    notifyListeners();
    await _save(await _prefs, _hapticKey, value);
  }

  Future<void> _save(
    SharedPreferences preferences,
    String key,
    Object value,
  ) async {
    final saved = switch (value) {
      double value => await preferences.setDouble(key, value),
      bool value => await preferences.setBool(key, value),
      _ => false,
    };
    if (!saved) {
      throw StateError('설정 값을 기기에 저장하지 못했습니다.');
    }
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
