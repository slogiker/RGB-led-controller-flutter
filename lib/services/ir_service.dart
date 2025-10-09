
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class IrService {
  static const _channel = MethodChannel('ir_channel');

  static Future<void> transmitHex(String hexCode, int frequency) async {
    try {
      await _channel.invokeMethod('transmitHex', {
        'hexCode': hexCode,
        'frequency': frequency,
      });
    } on PlatformException catch (e) {
      developer.log("Failed to transmit IR code: '${e.message}'.");
    }
  }
}
