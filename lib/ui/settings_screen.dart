

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/vibrate_settings.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _vibrationHardness = 50;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVibrationSettings();
  }

  Future<void> _loadVibrationSettings() async {
    final hardness = await VibrateSettings.getVibrationHardness();
    setState(() {
      _vibrationHardness = hardness;
      _isLoading = false;
    });
  }

  /// Launch URL in default browser
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vibration Hardness',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _vibrationHardness == 0
                            ? 'Off'
                            : '${_vibrationHardness.toInt()}%',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: _vibrationHardness,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: _vibrationHardness == 0 ? 'Off' : '${_vibrationHardness.toInt()}%',
                        activeColor: Colors.deepPurpleAccent,
                        inactiveColor: Colors.grey.shade700,
                        onChanged: (double value) async {
                          setState(() {
                            _vibrationHardness = value;
                          });
                          await VibrateSettings.setVibrationHardness(value);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: Text(themeProvider.isDarkMode ? 'Enabled' : 'Disabled'),
                      value: themeProvider.isDarkMode,
                      onChanged: (bool value) {
                        themeProvider.setDarkMode(value);
                      },
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('About'),
                  subtitle: const Text('RGB LED Controller v1.0'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: AppConstants.appName,
                      applicationVersion: AppConstants.appVersion,
                      applicationLegalese: AppConstants.copyright,
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Developer'),
                  subtitle: const Text('Built by slogiker'),
                  leading: const Icon(Icons.person),
                ),
                const Divider(),
                ListTile(
                  title: const Text('GitHub Repository'),
                  subtitle: const Text('View source code'),
                  leading: const Icon(Icons.code),
                  onTap: () => _launchUrl(AppConstants.githubRepo),
                ),
              ],
            ),
    );
  }
}