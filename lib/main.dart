import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/ui/remote_screen.dart';
import 'package:myapp/providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..loadThemeMode(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'RGB LED Remote',
            theme: themeProvider.getThemeData(),
            home: const RemoteScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
