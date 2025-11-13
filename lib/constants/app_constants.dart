import 'package:flutter/material.dart';

/// Application-wide constants for styling and configuration
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // Color constants
  static const Color darkBg = Color(0xFF121212);
  static const Color darkContainerBg = Color(0xFF1A1A1A);
  static const Color lightContainerBg = Color(0xFFE8E8E8);
  
  static const Color primaryColor = Colors.deepPurpleAccent;
  static const Color accentColor = Colors.deepPurple;

  // Border & Shadow constants
  static const double borderRadius = 30.0;
  static const double buttonRadius = 30.0;
  static const double buttonSize = 60.0;
  static const double powerButtonSize = 100.0;
  static const double irIndicatorSize = 16.0;

  // Padding & Spacing constants
  static const EdgeInsets containerPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 32.0,
  );
  static const EdgeInsets screenMargin = EdgeInsets.symmetric(horizontal: 16.0);

  // Animation constants
  static const Duration irIndicatorDuration = Duration(milliseconds: 500);
  static const Duration transitionDuration = Duration(milliseconds: 300);

  // Brightness threshold for slider
  static const int brightnessThreshold = 50;

  // Developer info
  static const String appName = 'RGB LED Controller';
  static const String appVersion = '1.0.0';
  static const String developer = 'slogiker';
  static const String githubRepo = 'https://github.com/slogiker/RGB-led-controller-flutter';
  static const String copyright = '©2025';
}
