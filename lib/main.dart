import 'package:flutter/material.dart';
import 'package:domain_investigator/screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.system) {
        final brightness = MediaQueryData.fromView(View.of(context)).platformBrightness;
        _themeMode = brightness == Brightness.light ? ThemeMode.dark : ThemeMode.light;
      } else {
        _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Domain Investigator',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        colorScheme: ColorScheme.light(
          primary: Colors.blueAccent.shade700,
          secondary: Colors.teal.shade700,
          surface: Colors.white,
          background: const Color(0xFFF0F2F5),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0D1117),
        scaffoldBackgroundColor: const Color(0xFF010409),
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent.shade400,
          secondary: Colors.tealAccent,
          surface: const Color(0xFF161B22),
          background: const Color(0xFF010409),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: HomePage(onThemeToggle: _toggleTheme),
    );
  }
}
