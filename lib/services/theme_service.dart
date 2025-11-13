import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'isDarkMode';

  /// Get the current theme mode
  /// Returns true for dark mode, false for light mode
  /// Defaults to true (dark mode) if not set
  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? true;
  }

  /// Set the theme mode
  /// true for dark mode, false for light mode
  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  /// Toggle between dark and light mode
  static Future<bool> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMode = prefs.getBool(_themeKey) ?? true;
    final newMode = !currentMode;
    await prefs.setBool(_themeKey, newMode);
    return newMode;
  }
}
