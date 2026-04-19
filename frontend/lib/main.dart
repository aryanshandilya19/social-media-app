import 'package:flutter/material.dart';
import 'core/app_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF020617),
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        colorScheme: const ColorScheme.dark(primary: Color(0xFF6366F1)),

        cardColor: const Color(0xFF1E293B),

        // ✅ FIXED BUTTON STYLE (COMPATIBLE)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
          ),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E293B),

          labelStyle: TextStyle(color: Colors.white70),

          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),

          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),

      home: const AppLauncher(),
    );
  }
}
