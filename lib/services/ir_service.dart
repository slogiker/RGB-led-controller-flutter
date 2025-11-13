import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// IR Service for transmitting infrared commands to LED controller
/// Supports all Android devices with IR blaster capability
/// Tested on: Xiaomi and other IR-equipped devices
class IrService {
  static const MethodChannel _channel = MethodChannel('ir_service');
  
  // Debounce mechanism to prevent command spam
  static Timer? _debounceTimer;
  static DateTime? _lastCommandTime;
  static const Duration _minCommandInterval = Duration(milliseconds: 100);

  // IR codes for each command (NEC protocol format)
  static const Map<String, String> irCodes = {
    'BRIGHT_UP': '0xF7C03F',
    'BRIGHT_DOWN': '0xF7E01F',
    'OFF': '0xF740BF',
    'ON': '0xF7C03F',
    'RED': '0xF720DF',
    'GREEN': '0xF7A05F',
    'BLUE': '0xF7609F',
    'WHITE': '0xF7E01F',
    'ORANGE': '0xF710EF',
    'TURQUOISE': '0xF7906F',
    'PURPLE': '0xF750AF',
    'YELLOW_ORANGE': '0xF730CF',
    'LIGHT_TURQUOISE': '0xF7B04F',
    'LIGHT_PURPLE': '0xF7708F',
    'YELLOW': '0xF708F7',
    'CYAN': '0xF78877',
    'PINK': '0xF748B7',
    'FLASH': '0xF7D02F',
    'STROBE': '0xF7F00F',
    'FADE': '0xF7C837',
    'SMOOTH': '0xF7E817'
  };

  /// Transmit IR command with debouncing and error handling
  /// 
  /// [command] - The command name (must exist in irCodes map)
  /// Returns true if command was sent, false if rejected (debounce)
  static Future<bool> transmitIR(String command) async {
    try {
      // Validate command
      if (!irCodes.containsKey(command)) {
        debugPrintError('❌ Invalid IR command: $command');
        return false;
      }

      // Debounce check - prevent command spam
      final now = DateTime.now();
      if (_lastCommandTime != null &&
          now.difference(_lastCommandTime!).inMilliseconds < _minCommandInterval.inMilliseconds) {
        debugPrintWarning('⏱️  Command rejected (debounced): $command');
        return false;
      }

      _lastCommandTime = now;
      final code = irCodes[command]!;

      debugPrintInfo('📤 Transmitting IR: $command ($code)');

      // Transmit via native method
      await _channel.invokeMethod('transmitIR', {
        'code': code,
        'command': command,
      });

      // Provide haptic feedback
      await HapticFeedback.mediumImpact();
      debugPrintSuccess('✅ IR transmitted successfully: $command');

      return true;
    } on PlatformException catch (e) {
      debugPrintError('❌ Platform Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrintError('❌ Error transmitting IR code: $e');
      return false;
    }
  }

  /// Check if device has IR blaster capability
  static Future<bool> hasIrBlaster() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasIrBlaster') ?? false;
      return result;
    } catch (e) {
      debugPrintWarning('⚠️  Could not determine IR blaster capability: $e');
      return false;
    }
  }

  /// Get IR blaster info (device manufacturer, model, etc.)
  static Future<Map<String, dynamic>> getIrBlasterInfo() async {
    try {
      final result = await _channel.invokeMethod<Map>('getIrBlasterInfo');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      debugPrintWarning('⚠️  Could not get IR blaster info: $e');
      return {};
    }
  }

  /// Test IR transmission (for emulator testing)
  static Future<void> testIR(String command) async {
    try {
      if (!irCodes.containsKey(command)) {
        debugPrintError('❌ Invalid test command: $command');
        return;
      }

      debugPrintInfo('🧪 Testing IR command: $command');
      await transmitIR(command);
      debugPrintSuccess('✅ Test IR command completed: $command');
    } catch (e) {
      debugPrintError('❌ Test IR failed: $e');
    }
  }

  /// Cancel any pending debounce timers
  static void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}

/// Debug print helpers for better visibility
void debugPrintInfo(String message) {
  debugPrint('ℹ️  $message');
}

void debugPrintSuccess(String message) {
  debugPrint('✅ $message');
}

void debugPrintWarning(String message) {
  debugPrint('⚠️  $message');
}

void debugPrintError(String message) {
  debugPrint('❌ $message');
}

