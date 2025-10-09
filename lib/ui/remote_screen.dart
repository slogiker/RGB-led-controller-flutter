
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:myapp/services/code_store.dart';
import 'package:myapp/services/ir_service.dart';
import 'package:myapp/ui/settings_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  final CodeStore _codeStore = CodeStore();
  Map<String, dynamic> _irCodes = {};
  Color _currentColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  Future<void> _loadCodes() async {
    final codes = await _codeStore.readCodes();
    setState(() {
      _irCodes = codes;
    });
  }

  void _transmit(String buttonName) {
    if (_irCodes.containsKey('buttons') &&
        _irCodes['buttons'].containsKey(buttonName)) {
      final hexCode = _irCodes['buttons'][buttonName];
      final frequency = _irCodes['meta']['frequency'];
      IrService.transmitHex(hexCode, frequency);
      Fluttertoast.showToast(
        msg: "Sent $buttonName",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _currentColor,
              onColorChanged: (color) {
                setState(() {
                  _currentColor = color;
                });
              },
              labelTypes: const [],
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LED IR Controller'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onCodesUpdated: _loadCodes,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircularButton(Icons.brightness_low, Colors.grey, () => _transmit('BRIGHT_DOWN')),
                _buildCircularButton(Icons.brightness_high, Colors.grey, () => _transmit('BRIGHT_UP')),
                _buildPowerButton('OFF', Colors.black, () => _transmit('OFF')),
                _buildPowerButton('ON', Colors.red, () => _transmit('ON')),
              ],
            ),
            const SizedBox(height: 20),

            // Color grid and effects
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildColorButton('R', Colors.red, () => _transmit('R')),
                        _buildColorButton('G', Colors.green, () => _transmit('G')),
                        _buildColorButton('B', Colors.blue, () => _transmit('B')),
                        _buildColorButton('W', Colors.white, () => _transmit('W')),
                        _buildColorButton('C1', Colors.orange, () => _transmit('C1')),
                        _buildColorButton('C2', Colors.lightGreen, () => _transmit('C2')),
                        _buildColorButton('C3', Colors.lightBlue, () => _transmit('C3')),
                        _buildColorButton('C4', Colors.pink, () => _transmit('C4')),
                        _buildColorButton('C5', Colors.amber, () => _transmit('C5')),
                        _buildColorButton('C6', Colors.cyan, () => _transmit('C6')),
                        _buildColorButton('C7', Colors.purple, () => _transmit('C7')),
                         GestureDetector(
                          onTap: _openColorPicker,
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _currentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildEffectButton('FLASH', () => _transmit('FLASH')),
                        _buildEffectButton('STROBE', () => _transmit('STROBE')),
                        _buildEffectButton('FADE', () => _transmit('FADE')),
                        _buildEffectButton('SMOOTH', () => _transmit('SMOOTH')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: color,
        padding: const EdgeInsets.all(20),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildPowerButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildColorButton(String text, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildEffectButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black)),
    );
  }
}
