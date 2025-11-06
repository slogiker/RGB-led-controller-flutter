import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/ui/remote_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.deepPurpleAccent,
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: GoogleFonts.robotoTextTheme(textTheme).apply(bodyColor: Colors.white),
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );

    return MaterialApp(
      title: 'RGB LED Remote',
      theme: darkTheme,
      home: const RemoteScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
