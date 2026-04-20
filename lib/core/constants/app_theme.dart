import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7EB8F7),
          secondary: Color(0xFFB8E0FF),
          surface: Colors.transparent,
          // ignore: deprecated_member_use
          background: Color(0xFF0D0D1A),
        ),
        cardTheme: const CardThemeData(elevation: 0, color: Colors.transparent),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: GoogleFonts.interTextTheme(
          const TextTheme(
            displayLarge: TextStyle(fontSize: 80, fontWeight: FontWeight.w200, letterSpacing: -2, color: Colors.white),
            displayMedium: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: Colors.white),
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
            bodyMedium: TextStyle(fontSize: 14, color: Color(0xB3FFFFFF)),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
      );
}
