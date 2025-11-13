import 'package:shared_preferences/shared_preferences.dart';

class VibrateSettings {
  static const String _enabledKey = 'vibrateOnButton';
  static const String _hardnessKey = 'vibrateHardness';

  static Future<bool> getVibrate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  static Future<void> setVibrate(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  /// Get vibration hardness as percentage (0-100)
  /// 0 means vibration is disabled
  static Future<double> getVibrationHardness() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_hardnessKey) ?? 50;
  }

  /// Set vibration hardness as percentage (0-100)
  /// 0 means vibration is disabled
  static Future<void> setVibrationHardness(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_hardnessKey, value);
  }
}
