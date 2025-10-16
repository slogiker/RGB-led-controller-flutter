import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/ui/remote_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyC-3prgVuu6QXjXZqkBGeAAEeWH9tpICoI",
        authDomain: "rgb-led-controller-flutter.firebaseapp.com",
        projectId: "rgb-led-controller-flutter",
        storageBucket: "rgb-led-controller-flutter.firebasestorage.app",
        messagingSenderId: "358704228013",
        appId: "1:358704228013:web:810274f785fd3a4bde4824",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('themeMode');
    if (theme == 'light') {
      setState(() {
        _themeMode = ThemeMode.light;
      });
    } else if (theme == 'dark') {
      setState(() {
        _themeMode = ThemeMode.dark;
      });
    }
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    _saveThemeMode(themeMode);
  }

  void _saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', themeMode.toString().split('.').last);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED IR Controller',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF212121),
        cardColor: const Color(0xFF3A3C40),
      ),
      themeMode: _themeMode,
      home: const RemoteScreen(),
    );
  }
}
