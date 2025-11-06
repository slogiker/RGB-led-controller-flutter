import 'package:flutter/services.dart';

class IrService {
  static const MethodChannel _channel = MethodChannel('ir_service');

  // IR codes for each function
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

  static Future<void> transmitIR(String command) async {
    try {
      final code = irCodes[command];
      if (code != null) {
        await _channel.invokeMethod('transmitIR', {'code': code});
        // Provide haptic feedback on successful transmission
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      print('Error transmitting IR code: $e');
    }
  }
}
