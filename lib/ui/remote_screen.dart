import 'package:flutter/material.dart';
import 'package:myapp/providers/remote_provider.dart';
import 'package:myapp/ui/settings_screen.dart';
import 'package:myapp/constants/app_constants.dart';
import 'package:myapp/utils/theme_helper.dart';
import 'package:myapp/widgets/custom_buttons.dart';
import 'package:provider/provider.dart';

class RemoteScreen extends StatelessWidget {
  const RemoteScreen({super.key});

  /// Build brightness slider widget
  Widget _buildBrightnessSlider(
    BuildContext context,
    RemoteProvider remoteProvider,
  ) {
    int brightnessPct = remoteProvider.brightnessValue.toInt();
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
          value: remoteProvider.brightnessValue,
          min: 0,
          max: 100,
          divisions: 100,
          label: '$brightnessPct%',
          activeColor: AppConstants.primaryColor,
          inactiveColor:
              isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
          onChanged: remoteProvider.handleBrightnessChange,
          onChangeEnd: (double value) {
            debugPrint('🔆 Brightness Slider Released at: ${value.toInt()}%');
          },
        ),
      ],
    );
  }

  /// Build row of buttons
  Widget _buildButtonRow(
    List<Map<String, dynamic>> buttons,
    bool isDarkMode,
    RemoteProvider remoteProvider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.map((button) {
        if (button.containsKey('text')) {
          return CustomEffectButton(
            text: button['text'] as String,
            command: button['command'] as String,
            isDarkMode: isDarkMode,
            onPressed: () => remoteProvider.sendIrCommand(
              button['command'] as String,
            ),
          );
        } else {
          return CustomColorButton(
            buttonColor: button['color'] as Color,
            command: button['command'] as String,
            isDarkMode: isDarkMode,
            onPressed: () => remoteProvider.sendIrCommand(
              button['command'] as String,
            ),
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
              child: Consumer<RemoteProvider>(
                builder: (context, remoteProvider, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIrIndicator(
                        isActive: remoteProvider.isIrActive,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      CustomPowerButton(
                        isPowerOn: remoteProvider.isPowerOn,
                        lastDebugMessage: remoteProvider.lastDebugMessage,
                        onPressed: remoteProvider.handlePowerToggle,
                      ),
                      const SizedBox(height: 24),
                      _buildBrightnessSlider(context, remoteProvider),
                      const SizedBox(height: 24),
                      _buildButtonRow([
                        {'color': Colors.red, 'command': 'RED'},
                        {'color': Colors.green, 'command': 'GREEN'},
                        {'color': Colors.blue, 'command': 'BLUE'},
                        {'color': Colors.white, 'command': 'WHITE'},
                      ], isDarkMode, remoteProvider),
                      const SizedBox(height: 16),
                      _buildButtonRow([
                        {'color': Colors.orange, 'command': 'ORANGE'},
                        {'color': Colors.cyan.shade300, 'command': 'TURQUOISE'},
                        {'color': Colors.purple, 'command': 'PURPLE'},
                        {'text': 'FLASH', 'command': 'FLASH'},
                      ], isDarkMode, remoteProvider),
                      const SizedBox(height: 16),
                      _buildButtonRow([
                        {
                          'color': Colors.orange.shade300,
                          'command': 'YELLOW_ORANGE'
                        },
                        {
                          'color': Colors.cyan.shade200,
                          'command': 'LIGHT_TURQUOISE'
                        },
                        {
                          'color': Colors.purple.shade200,
                          'command': 'LIGHT_PURPLE'
                        },
                        {'text': 'STROBE', 'command': 'STROBE'},
                      ], isDarkMode, remoteProvider),
                      const SizedBox(height: 16),
                      _buildButtonRow([
                        {
                          'color': Colors.yellow.shade600,
                          'command': 'YELLOW_ORANGE'
                        },
                        {'color': Colors.cyan, 'command': 'CYAN'},
                        {'color': Colors.pink.shade300, 'command': 'PINK'},
                        {'text': 'FADE', 'command': 'FADE'},
                      ], isDarkMode, remoteProvider),
                      const SizedBox(height: 16),
                      _buildButtonRow([
                        {'color': Colors.yellow, 'command': 'YELLOW'},
                        {'color': Colors.cyan.shade100, 'command': 'CYAN'},
                        {'color': Colors.pink, 'command': 'PINK'},
                        {'text': 'SMOOTH', 'command': 'SMOOTH'},
                      ], isDarkMode, remoteProvider),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
