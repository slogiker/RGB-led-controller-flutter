
import 'package:flutter/material.dart';
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
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.orange),
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
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
              color: const Color(0xFF4a4a4a),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.black.withAlpha(51)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(128),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ]),
          width: 300,
          child: _buildRemoteGrid(),
        ),
      ),
    );
  }

  Widget _buildRemoteGrid() {
    final List<Map<String, dynamic>> buttons = [
      // Row 1
      {
        'child': Icon(Icons.wb_sunny_outlined, color: Colors.black.withAlpha(178)),
        'color': Colors.white,
        'name': 'BRIGHT_UP'
      },
      {
        'child': Icon(Icons.wb_sunny, color: Colors.black.withAlpha(178)),
        'color': Colors.white,
        'name': 'BRIGHT_DOWN'
      },
      {'text': 'OFF', 'color': const Color(0xFF2d2d2d), 'name': 'OFF'},
      {'text': 'ON', 'color': const Color(0xFFd93131), 'name': 'ON'},
      // Row 2
      {'text': 'R', 'color': const Color(0xFFd93131), 'name': 'R'},
      {'text': 'G', 'color': const Color(0xFF31d931), 'name': 'G'},
      {'text': 'B', 'color': const Color(0xFF3131d9), 'name': 'B'},
      {
        'text': 'W',
        'color': Colors.white,
        'textColor': Colors.black,
        'name': 'W'
      },
      // Row 3
      {'color': const Color(0xFFf47920), 'name': 'C1'},
      {'color': const Color(0xFF00a651), 'name': 'C2'},
      {'color': const Color(0xFF0072bc), 'name': 'C3'},
      {
        'text': 'FLASH',
        'color': const Color(0xFF6e6e6e),
        'textSize': 10.0,
        'name': 'FLASH'
      },
      // Row 4
      {'color': const Color(0xFFf4a261), 'name': 'C4'},
      {'color': const Color(0xFF2a9d8f), 'name': 'C5'},
      {'color': const Color(0xFF6a4c93), 'name': 'C6'},
      {
        'text': 'STROBE',
        'color': const Color(0xFF6e6e6e),
        'textSize': 10.0,
        'name': 'STROBE'
      },
      // Row 5
      {'color': const Color(0xFFf9c74f), 'name': 'C7'},
      {'color': const Color(0xFF277da1), 'name': 'C8'},
      {'color': const Color(0xFFe5989b), 'name': 'C9'},
      {
        'text': 'FADE',
        'color': const Color(0xFF6e6e6e),
        'textSize': 10.0,
        'name': 'FADE'
      },
      // Row 6
      {'color': const Color(0xFFf4e285), 'name': 'C10'},
      {'color': const Color(0xFF83c5be), 'name': 'C11'},
      {'color': const Color(0xFFe07a5f), 'name': 'C12'},
      {
        'text': 'SMOOTH',
        'color': const Color(0xFF6e6e6e),
        'textSize': 10.0,
        'name': 'SMOOTH'
      },
    ];

    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: buttons.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15
        ),
        itemBuilder: (context, index) {
          final buttonConfig = buttons[index];
          return _RemoteButton(
            color: buttonConfig['color'],
            text: buttonConfig['text'],
            textColor: buttonConfig['textColor'],
            child: buttonConfig['child'],
            onPressed: () => _transmit(buttonConfig['name']),
            size: 50,
            textSize: buttonConfig['textSize'] ?? 16.0,
          );
        });
  }
}

class _RemoteButton extends StatefulWidget {
  final Color? color;
  final String? text;
  final Color? textColor;
  final Widget? child;
  final VoidCallback? onPressed;
  final double size;
  final double textSize;

  const _RemoteButton({
    this.color,
    this.text,
    this.textColor,
    this.child,
    this.onPressed,
    this.size = 50.0,
    this.textSize = 16.0,
  });

  @override
  _RemoteButtonState createState() => _RemoteButtonState();
}

class _RemoteButtonState extends State<_RemoteButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      widget.onPressed!();
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
  }

  Color _getSlightlyLighter(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.05).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? const Color(0xFF6e6e6e);
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: buttonColor,
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [_getSlightlyLighter(buttonColor), buttonColor],
              center: Alignment.center,
              radius: 0.7,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(102),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: widget.child ??
                (widget.text != null
                    ? Text(
                        widget.text!,
                        style: TextStyle(
                          color: widget.textColor ?? Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: widget.textSize,
                        ),
                      )
                    : null),
          ),
        ),
      ),
    );
  }
}
