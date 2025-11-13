import 'package:flutter/material.dart';
import 'package:myapp/services/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  late bool _isDarkMode;

  ThemeProvider({bool initialDarkMode = true}) {
    _isDarkMode = initialDarkMode;
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> loadThemeMode() async {
    _isDarkMode = await ThemeService.isDarkMode();
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    await ThemeService.setDarkMode(isDark);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = await ThemeService.toggleTheme();
    notifyListeners();
  }

  ThemeData getThemeData() {
    if (_isDarkMode) {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurpleAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: TextTheme(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.white),
          bodySmall: const TextStyle(color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      );
    } else {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          backgroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      );
    }
  }
}
