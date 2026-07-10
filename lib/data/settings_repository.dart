import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class SettingsRepository {
  static const _keyThemeMode = 'settings.themeMode';
  static const _keySoundOn = 'settings.soundOn';
  static const _keyVibrationOn = 'settings.vibrationOn';
  static const _keyOnboardingShown = 'settings.onboardingShown';

  Future<AppThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyThemeMode);
    return AppThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => AppThemeMode.system,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  Future<bool> getSoundOn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySoundOn) ?? true;
  }

  Future<void> setSoundOn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundOn, value);
  }

  Future<bool> getVibrationOn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVibrationOn) ?? true;
  }

  Future<void> setVibrationOn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibrationOn, value);
  }

  Future<bool> getOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingShown) ?? false;
  }

  Future<void> setOnboardingShown(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingShown, value);
  }
}
