import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/services/ir_service.dart';
import 'package:myapp/ui/settings_screen.dart';

class RemoteScreen extends StatelessWidget {
  const RemoteScreen({super.key});

  void _sendIrCommand(String command) {
    IrService.transmitIR(command);
  }

  @override
  Widget build(BuildContext context) {
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
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.grey.shade800,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                _buildControlRow([
                  {'icon': Icons.add, 'command': 'BRIGHT_UP'},
                  {'icon': Icons.remove, 'command': 'BRIGHT_DOWN'},
                  {'icon': Icons.power_settings_new, 'command': 'OFF', 'color': Colors.red},
                  {'icon': Icons.power_settings_new, 'command': 'ON', 'color': Colors.green},
                ]),
                const SizedBox(height: 24),
                _buildColorRow([
                  {'color': Colors.red, 'command': 'RED'},
                  {'color': Colors.green, 'command': 'GREEN'},
                  {'color': Colors.blue, 'command': 'BLUE'},
                  {'color': Colors.white, 'command': 'WHITE'},
                ]),
                const SizedBox(height: 16),
                _buildColorRow([
                  {'color': Colors.orange, 'command': 'ORANGE'},
                  {'color': Colors.cyan.shade300, 'command': 'TURQUOISE'},
                  {'color': Colors.purple, 'command': 'PURPLE'},
                  {'text': 'FLASH', 'command': 'FLASH'},
                ]),
                const SizedBox(height: 16),
                _buildColorRow([
                  {'color': Colors.orange.shade300, 'command': 'YELLOW_ORANGE'},
                  {'color': Colors.cyan.shade200, 'command': 'LIGHT_TURQUOISE'},
                  {'color': Colors.purple.shade200, 'command': 'LIGHT_PURPLE'},
                  {'text': 'STROBE', 'command': 'STROBE'},
                ]),
                const SizedBox(height: 16),
                _buildColorRow([
                  {'color': Colors.yellow.shade600, 'command': 'YELLOW_ORANGE'},
                  {'color': Colors.cyan, 'command': 'CYAN'},
                  {'color': Colors.pink.shade300, 'command': 'PINK'},
                  {'text': 'FADE', 'command': 'FADE'},
                ]),
                const SizedBox(height: 16),
                _buildColorRow([
                  {'color': Colors.yellow, 'command': 'YELLOW'},
                  {'color': Colors.cyan.shade100, 'command': 'CYAN'},
                  {'color': Colors.pink, 'command': 'PINK'},
                  {'text': 'SMOOTH', 'command': 'SMOOTH'},
                ]),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlRow(List<Map<String, dynamic>> controls) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: controls.map((control) {
        return _buildControlButton(
          icon: control['icon'] as IconData,
          command: control['command'] as String,
          color: control['color'] as Color? ?? Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildColorRow(List<Map<String, dynamic>> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.map((button) {
        if (button.containsKey('text')) {
          return _buildEffectButton(
            text: button['text'] as String,
            command: button['command'] as String,
          );
        } else {
          return _buildColorButton(
            color: button['color'] as Color,
            command: button['command'] as String,
          );
        }
      }).toList(),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String command,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _sendIrCommand(command),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade900,
            border: Border.all(color: Colors.grey.shade800, width: 1),
            boxShadow: [
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
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade800,
                Colors.grey.shade900,
              ],
            ),
          ),
          child: Icon(icon, color: color),
        ),
      ),
    );
  }

  Widget _buildColorButton({
    required Color color,
    required String command,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _sendIrCommand(command),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.grey.shade800, width: 1),
            boxShadow: [
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
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.9),
                color,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEffectButton({
    required String text,
    required String command,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _sendIrCommand(command),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade900,
            border: Border.all(color: Colors.grey.shade800, width: 1),
            boxShadow: [
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
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade800,
                Colors.grey.shade900,
              ],
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
