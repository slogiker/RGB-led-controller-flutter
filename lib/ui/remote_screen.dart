import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:myapp/services/ir_service.dart';
import 'package:myapp/ui/settings_screen.dart';

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  Map<String, String> _irCodes = {};

  @override
  void initState() {
    super.initState();
    _loadIrCodes();
  }

  Future<void> _loadIrCodes() async {
    final String response = await rootBundle.loadString('assets/ir_codes.json');
    final data = await json.decode(response);
    setState(() {
      _irCodes = Map<String, String>.from(data);
    });
  }

  void _sendIrCommand(String key) {
    final code = _irCodes[key];
    if (code != null) {
      IrService.transmitIR(code);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RGB LED Remote',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen(onCodesUpdated: _loadIrCodes)),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/images/noise.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withAlpha(25), BlendMode.dstATop),
          ),
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade900, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPowerButtons(),
              _buildColorGrid(),
              _buildBrightnessSlider(),
              _buildSpeedSlider(),
              _buildEffectButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(Icons.power_settings_new, Colors.greenAccent, 'power_on'),
        _buildIconButton(Icons.power_off, Colors.redAccent, 'power_off'),
      ],
    );
  }

  Widget _buildColorGrid() {
    final List<Map<String, dynamic>> colors = [
      {'color': Colors.red, 'key': 'red'},
      {'color': Colors.green, 'key': 'green'},
      {'color': Colors.blue, 'key': 'blue'},
      {'color': Colors.white, 'key': 'white'},
      {'color': Colors.orange, 'key': 'orange'},
      {'color': Colors.lightGreen, 'key': 'light_green'},
      {'color': Colors.lightBlue, 'key': 'light_blue'},
      {'color': Colors.amber, 'key': 'amber'},
      {'color': Colors.cyan, 'key': 'cyan'},
      {'color': Colors.purple, 'key': 'purple'},
      {'color': Colors.yellow, 'key': 'yellow'},
      {'color': Colors.pink, 'key': 'pink'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index]['color'] as Color;
        final key = colors[index]['key'] as String;
        return _buildColorButton(color, key);
      },
    );
  }

  Widget _buildBrightnessSlider() {
    return _buildSlider('Brightness', Icons.wb_sunny, 'brightness_down', 'brightness_up');
  }

  Widget _buildSpeedSlider() {
    return _buildSlider('Speed', Icons.speed, 'smooth', 'flash'); // Using smooth/flash as placeholders
  }

  Widget _buildSlider(String label, IconData icon, String keyDecrease, String keyIncrease) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildSmallIconButton(icon, keyDecrease),
            const Expanded(
              child: Slider(
                value: 0.5, // Dummy value
                onChanged: null, // Disabled
                activeColor: Colors.purpleAccent,
                inactiveColor: Colors.grey,
              ),
            ),
            _buildSmallIconButton(icon, keyIncrease, increment: true),
          ],
        ),
      ],
    );
  }

  Widget _buildEffectButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTextButton('Flash', 'flash'),
        _buildTextButton('Strobe', 'strobe'),
        _buildTextButton('Fade', 'fade'),
        _buildTextButton('Smooth', 'smooth'),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, Color color, String key) {
    return InkWell(
      onTap: () => _sendIrCommand(key),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withAlpha(50),
          boxShadow: [
            BoxShadow(
                color: Colors.deepPurple.shade900.withAlpha(128),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(5, 5)),
            BoxShadow(
                color: Colors.blue.shade900.withAlpha(128),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(-5, -5)),
          ],
        ),
        child: Icon(icon, color: color, size: 35),
      ),
    );
  }

  Widget _buildSmallIconButton(IconData icon, String key, {bool increment = false}) {
    return InkWell(
      onTap: () => _sendIrCommand(key),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withAlpha(50),
        ),
        child: Icon(increment ? Icons.add : Icons.remove, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildColorButton(Color color, String key) {
    return InkWell(
      onTap: () => _sendIrCommand(key),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(128),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(String label, String key) {
    return InkWell(
      onTap: () => _sendIrCommand(key),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(50),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
             BoxShadow(
                color: Colors.deepPurple.shade900.withAlpha(128),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(3, 3)),
             BoxShadow(
                color: Colors.blue.shade900.withAlpha(128),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(-3, -3)),
          ],
        ),
        child: Text(label, style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}
