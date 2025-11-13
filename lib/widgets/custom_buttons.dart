import 'package:flutter/material.dart';
import 'package:myapp/constants/app_constants.dart';
import 'package:myapp/utils/theme_helper.dart';

// Pre-calculated shadows for performance
const _buttonShadows = [
  BoxShadow(
    color: Color.fromARGB(128, 0, 0, 0),
    blurRadius: 4,
    offset: Offset(0, 2),
  ),
  BoxShadow(
    color: Colors.black,
    spreadRadius: -1,
    blurRadius: 1,
  ),
];

/// Custom circular button widget for control actions
class CustomControlButton extends StatelessWidget {
  final IconData icon;
  final String command;
  final Color iconColor;
  final VoidCallback onPressed;
  final bool isDarkMode;

  const CustomControlButton({
    Key? key,
    required this.icon,
    required this.command,
    required this.iconColor,
    required this.onPressed,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = ThemeHelper.getButtonColor(isDarkMode);
    final borderColor = ThemeHelper.getBorderColor(isDarkMode);
    final gradientColors = ThemeHelper.getButtonGradientColors(isDarkMode);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        child: Container(
          width: AppConstants.buttonSize,
          height: AppConstants.buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: buttonColor,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: _buttonShadows,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: Icon(icon, color: iconColor),
        ),
      ),
    );
  }
}

/// Custom circular button widget for color selection
class CustomColorButton extends StatelessWidget {
  final Color buttonColor;
  final String command;
  final VoidCallback onPressed;
  final bool isDarkMode;

  const CustomColorButton({
    Key? key,
    required this.buttonColor,
    required this.command,
    required this.onPressed,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderColor = ThemeHelper.getBorderColor(isDarkMode);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        child: Container(
          width: AppConstants.buttonSize,
          height: AppConstants.buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: buttonColor,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: _buttonShadows,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                buttonColor.withOpacity(0.9),
                buttonColor,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom circular button widget for effect/action buttons (FLASH, STROBE, etc.)
class CustomEffectButton extends StatelessWidget {
  final String text;
  final String command;
  final VoidCallback onPressed;
  final bool isDarkMode;

  const CustomEffectButton({
    Key? key,
    required this.text,
    required this.command,
    required this.onPressed,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = ThemeHelper.getButtonColor(isDarkMode);
    final borderColor = ThemeHelper.getBorderColor(isDarkMode);
    final gradientColors = ThemeHelper.getButtonGradientColors(isDarkMode);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        child: Container(
          width: AppConstants.buttonSize,
          height: AppConstants.buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: buttonColor,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: _buttonShadows,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom power button widget with toggle state
class CustomPowerButton extends StatelessWidget {
  final bool isPowerOn;
  final String? lastDebugMessage;
  final VoidCallback onPressed;

  const CustomPowerButton({
    Key? key,
    required this.isPowerOn,
    required this.lastDebugMessage,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: AppConstants.powerButtonSize,
            height: AppConstants.powerButtonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPowerOn ? Colors.green : Colors.grey.shade900,
              border: Border.all(
                color: isPowerOn ? Colors.green.shade400 : Colors.grey.shade800,
                width: 2,
              ),
              boxShadow: [ThemeHelper.getPowerButtonShadow(isPowerOn)],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isPowerOn
                    ? [Colors.green.shade600, Colors.green]
                    : [Colors.grey.shade800, Colors.grey.shade900],
              ),
            ),
            child: Icon(
              Icons.power_settings_new,
              size: 48,
              color: isPowerOn ? Colors.white : Colors.red,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isPowerOn ? 'ON' : 'OFF',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isPowerOn ? Colors.green : Colors.red,
          ),
        ),
        if (lastDebugMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              lastDebugMessage!,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.3),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

/// Custom IR indicator light widget
class CustomIrIndicator extends StatelessWidget {
  final bool isActive;
  final bool isDarkMode;

  const CustomIrIndicator({
    Key? key,
    required this.isActive,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inactiveColor = ThemeHelper.getIrInactiveColor(isDarkMode);
    final activeColor = ThemeHelper.getIrActiveColor();

    return Center(
      child: Container(
        width: AppConstants.irIndicatorSize,
        height: AppConstants.irIndicatorSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? activeColor : inactiveColor,
          boxShadow: isActive ? ThemeHelper.getIrActiveShadow() : [],
        ),
      ),
    );
  }
}
