import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:myapp/constants/app_constants.dart';
import 'package:myapp/services/ir_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteProvider extends ChangeNotifier {
  static const String _powerKey = 'remote_power_state';

  bool _isPowerOn = false;
  double _brightnessValue = 50.0;
  bool _isIrActive = false;
  String? _lastDebugMessage;
  int _lastBrightnessSent = 50;

  RemoteProvider() {
    _loadPersistedState();
  }

  bool get isPowerOn => _isPowerOn;
  double get brightnessValue => _brightnessValue;
  bool get isIrActive => _isIrActive;
  String? get lastDebugMessage => _lastDebugMessage;

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    _isPowerOn = prefs.getBool(_powerKey) ?? false;
    notifyListeners();
  }

  Future<void> handlePowerToggle() async {
    _isPowerOn = !_isPowerOn;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_powerKey, _isPowerOn);

    final command = _isPowerOn ? 'ON' : 'OFF';
    await sendIrCommand(command);
  }

  void handleBrightnessChange(double value) {
    _brightnessValue = value;
    notifyListeners();

    if (!_isPowerOn) {
      return;
    }

    final currentPct = value.toInt();
    if ((currentPct - _lastBrightnessSent).abs() >= 5) {
      _lastBrightnessSent = currentPct;
      if (currentPct > AppConstants.brightnessThreshold) {
        sendIrCommand('BRIGHT_UP');
      } else if (currentPct < AppConstants.brightnessThreshold) {
        sendIrCommand('BRIGHT_DOWN');
      }
    }
  }

  Future<void> sendIrCommand(String command) async {
    if (!_isPowerOn && command != 'ON' && command != 'OFF') {
      debugPrint('🔴 IR Command Blocked: power is OFF, command: $command');
      return;
    }

    _isIrActive = true;
    _lastDebugMessage = command;
    notifyListeners();

    await IrService.transmitIR(command);

    Future.delayed(AppConstants.irIndicatorDuration, () {
      _isIrActive = false;
      notifyListeners();
    });
  }
}

