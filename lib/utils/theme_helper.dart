import 'package:flutter/material.dart';
import 'package:myapp/constants/app_constants.dart';

/// Helper class for theme-aware styling and color management
class ThemeHelper {
  ThemeHelper._(); // Private constructor to prevent instantiation

  /// Get button color based on theme mode
  static Color getButtonColor(bool isDarkMode) {
    return isDarkMode ? Colors.grey.shade900 : Colors.grey.shade400;
  }

  /// Get border color based on theme mode
  static Color getBorderColor(bool isDarkMode) {
    return isDarkMode ? Colors.grey.shade800 : Colors.grey.shade500;
  }

  /// Get gradient colors for buttons based on theme mode
  static List<Color> getButtonGradientColors(bool isDarkMode) {
    return isDarkMode
        ? [Colors.grey.shade800, Colors.grey.shade900]
        : [Colors.grey.shade300, Colors.grey.shade400];
  }

  /// Get container background color based on theme mode
  static Color getContainerBgColor(bool isDarkMode) {
    return isDarkMode ? AppConstants.darkContainerBg : AppConstants.lightContainerBg;
  }

  /// Get container border color based on theme mode
  static Color getContainerBorderColor(bool isDarkMode) {
    return isDarkMode ? Colors.grey.shade800 : Colors.grey.shade400;
  }

  /// Get IR indicator color when active
  static Color getIrActiveColor() {
    return Colors.red.shade600;
  }

  /// Get IR indicator color when inactive based on theme
  static Color getIrInactiveColor(bool isDarkMode) {
    return isDarkMode ? Colors.grey.shade800 : Colors.grey.shade400;
  }

  /// Get text color based on theme mode
  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white70 : Colors.black87;
  }

  /// Get shadow color based on theme mode
  static Color getShadowColor(bool isDarkMode) {
    return isDarkMode ? Colors.black : Colors.grey;
  }

  /// Build box shadow with theme awareness
  static List<BoxShadow> getButtonShadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
      const BoxShadow(
        color: Colors.black,
        spreadRadius: -1,
        blurRadius: 1,
      ),
    ];
  }

  /// Build container shadow with theme awareness
  static List<BoxShadow> getContainerShadow(bool isDarkMode) {
    return [
      BoxShadow(
        color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.5),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ];
  }

  /// Build power button shadow
  static BoxShadow getPowerButtonShadow(bool isPowerOn) {
    return BoxShadow(
      color: (isPowerOn ? Colors.green : Colors.black).withOpacity(0.7),
      blurRadius: isPowerOn ? 15 : 8,
      offset: const Offset(0, 4),
    );
  }

  /// Build IR indicator glow when active
  static List<BoxShadow> getIrActiveShadow() {
    return [
      BoxShadow(
        color: Colors.red.withOpacity(0.8),
        blurRadius: 8,
        spreadRadius: 2,
      ),
    ];
  }
}
