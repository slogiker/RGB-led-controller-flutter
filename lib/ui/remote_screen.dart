import 'package:flutter/material.dart';
import 'package:myapp/services/ir_service.dart';
import 'package:myapp/ui/settings_screen.dart';
import 'package:myapp/constants/app_constants.dart';
import 'package:myapp/utils/theme_helper.dart';
import 'package:myapp/widgets/custom_buttons.dart';

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  late bool _isPowerOn;
  late double _brightnessValue;
  late bool _isIrActive;
  late String? _lastDebugMessage;
  late int _lastBrightnessSent;

  @override
  void initState() {
    super.initState();
    _resetState();
  }

  /// Initialize state variables
  void _resetState() {
    _isPowerOn = false;
    _brightnessValue = 50.0;
    _isIrActive = false;
    _lastDebugMessage = null;
    _lastBrightnessSent = 50;
  }

  /// Send IR command with visual and debug feedback
  void _sendIrCommand(String command) {
    debugPrint('🔴 IR Command Sent: $command (Toggle: $_isPowerOn)');

    setState(() {
      _isIrActive = true;
      _lastDebugMessage = command;
    });

    IrService.transmitIR(command);

    // Deactivate IR light after timeout
    Future.delayed(AppConstants.irIndicatorDuration, () {
      if (mounted) {
        setState(() {
          _isIrActive = false;
        });
      }
    });
  }

  /// Handle power button toggle
  void _handlePowerToggle() {
    setState(() => _isPowerOn = !_isPowerOn);
    String command = _isPowerOn ? 'ON' : 'OFF';
    _sendIrCommand(command);
    debugPrint('💡 Power Toggle: $_isPowerOn');
  }

  /// Handle brightness slider changes - throttled to reduce IR commands
  void _handleBrightnessChange(double value) {
    setState(() {
      _brightnessValue = value;
    });
    
    int currentPct = value.toInt();
    // Only send command if brightness changed by more than 5%
    if ((currentPct - _lastBrightnessSent).abs() >= 5) {
      _lastBrightnessSent = currentPct;
      if (currentPct > AppConstants.brightnessThreshold) {
        _sendIrCommand('BRIGHT_UP');
      } else if (currentPct < AppConstants.brightnessThreshold) {
        _sendIrCommand('BRIGHT_DOWN');
      }
    }
  }

  /// Build brightness slider widget
  Widget _buildBrightnessSlider() {
    int brightnessPct = _brightnessValue.toInt();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          'Brightness: $brightnessPct%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: ThemeHelper.getTextColor(isDarkMode),
          ),
        ),
        const SizedBox(height: 12),
        Slider(
          value: _brightnessValue,
          min: 0,
          max: 100,
          divisions: 100,
          label: '$brightnessPct%',
          activeColor: AppConstants.primaryColor,
          inactiveColor:
              isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
          onChanged: _handleBrightnessChange,
          onChangeEnd: (double value) {
            debugPrint('🔆 Brightness Slider Released at: ${value.toInt()}%');
          },
        ),
      ],
    );
  }

  /// Build row of buttons
  Widget _buildButtonRow(List<Map<String, dynamic>> buttons, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.map((button) {
        if (button.containsKey('text')) {
          return CustomEffectButton(
            text: button['text'] as String,
            command: button['command'] as String,
            isDarkMode: isDarkMode,
            onPressed: () => _sendIrCommand(button['command'] as String),
          );
        } else {
          return CustomColorButton(
            buttonColor: button['color'] as Color,
            command: button['command'] as String,
            isDarkMode: isDarkMode,
            onPressed: () => _sendIrCommand(button['command'] as String),
          );
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RGB LED Remote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: AppConstants.screenMargin,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: ThemeHelper.getContainerBgColor(isDarkMode),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: ThemeHelper.getContainerBorderColor(isDarkMode),
              width: 2,
            ),
            boxShadow: ThemeHelper.getContainerShadow(isDarkMode),
          ),
          child: Padding(
            padding: AppConstants.containerPadding,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIrIndicator(isActive: _isIrActive, isDarkMode: isDarkMode),
                  const SizedBox(height: 16),
                  CustomPowerButton(
                    isPowerOn: _isPowerOn,
                    lastDebugMessage: _lastDebugMessage,
                    onPressed: _handlePowerToggle,
                  ),
                  const SizedBox(height: 24),
                  _buildBrightnessSlider(),
                  const SizedBox(height: 24),
                  _buildButtonRow([
                    {'color': Colors.red, 'command': 'RED'},
                    {'color': Colors.green, 'command': 'GREEN'},
                    {'color': Colors.blue, 'command': 'BLUE'},
                    {'color': Colors.white, 'command': 'WHITE'},
                  ], isDarkMode),
                  const SizedBox(height: 16),
                  _buildButtonRow([
                    {'color': Colors.orange, 'command': 'ORANGE'},
                    {'color': Colors.cyan.shade300, 'command': 'TURQUOISE'},
                    {'color': Colors.purple, 'command': 'PURPLE'},
                    {'text': 'FLASH', 'command': 'FLASH'},
                  ], isDarkMode),
                  const SizedBox(height: 16),
                  _buildButtonRow([
                    {'color': Colors.orange.shade300, 'command': 'YELLOW_ORANGE'},
                    {'color': Colors.cyan.shade200, 'command': 'LIGHT_TURQUOISE'},
                    {'color': Colors.purple.shade200, 'command': 'LIGHT_PURPLE'},
                    {'text': 'STROBE', 'command': 'STROBE'},
                  ], isDarkMode),
                  const SizedBox(height: 16),
                  _buildButtonRow([
                    {'color': Colors.yellow.shade600, 'command': 'YELLOW_ORANGE'},
                    {'color': Colors.cyan, 'command': 'CYAN'},
                    {'color': Colors.pink.shade300, 'command': 'PINK'},
                    {'text': 'FADE', 'command': 'FADE'},
                  ], isDarkMode),
                  const SizedBox(height: 16),
                  _buildButtonRow([
                    {'color': Colors.yellow, 'command': 'YELLOW'},
                    {'color': Colors.cyan.shade100, 'command': 'CYAN'},
                    {'color': Colors.pink, 'command': 'PINK'},
                    {'text': 'SMOOTH', 'command': 'SMOOTH'},
                  ], isDarkMode),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
