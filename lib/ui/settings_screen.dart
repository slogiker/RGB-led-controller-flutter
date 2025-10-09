
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:myapp/services/code_store.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onCodesUpdated;

  const SettingsScreen({super.key, required this.onCodesUpdated});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final CodeStore _codeStore = CodeStore();
  int _codeCount = 0;
  String _lastUpdated = 'Never';

  @override
  void initState() {
    super.initState();
    _loadCodeInfo();
  }

  Future<void> _loadCodeInfo() async {
    final codes = await _codeStore.readCodes();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _codeCount = codes.containsKey('buttons') ? codes['buttons'].length : 0;
      _lastUpdated = prefs.getString('lastUpdated') ?? 'Never';
    });
  }

  Future<void> _importCodes() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      await _codeStore.mergeAndSaveCodes(file);
      widget.onCodesUpdated();
      await _loadCodeInfo();
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().toIso8601String();
      prefs.setString('lastUpdated', now);
      setState(() {
        _lastUpdated = now;
      });
      Fluttertoast.showToast(msg: 'Codes imported successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: MyApp.of(context).themeMode,
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (ThemeMode? theme) {
                if (theme != null) {
                  MyApp.of(context).changeTheme(theme);
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Import IR Codes'),
            subtitle: const Text('Import a JSON file with new IR codes'),
            onTap: _importCodes,
          ),
          ListTile(
            title: const Text('Loaded Codes'),
            subtitle: Text('$_codeCount codes loaded'),
          ),
          ListTile(
            title: const Text('Last Updated'),
            subtitle: Text(_lastUpdated),
          ),
        ],
      ),
    );
  }
}
