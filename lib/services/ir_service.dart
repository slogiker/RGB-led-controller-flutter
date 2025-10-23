import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class IrService {
  static const MethodChannel _channel = MethodChannel('ir_service');

  static Future<bool> transmitIR(String code) async {
    try {
      final bool result = await _channel.invokeMethod('transmitIR', {'code': code});
      return result;
    } on PlatformException catch (e) {
      developer.log("Failed to transmit IR: '${e.message}'.");
      return false;
    }
  }
}
