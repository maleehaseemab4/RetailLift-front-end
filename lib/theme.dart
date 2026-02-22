import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primaryBlue = Color(0xFF001F3F); // Deep Navy (Logo)
  static const Color _secondaryTeal = Color(0xFF003366); // Navy Blue
  static const Color _backgroundLight = Color(0xFFF5F7FA); // Cool Grey/White

  // Cold Blue Palette (Dark Mode)
  static const Color _backgroundCold = Color(0xFF0F172A); // Deep Slate
  static const Color _surfaceCold = Color(0xFF1E293B); // Dark Slate
  static const Color _iceBlue = Color(0xFF4DA8DA); // Primary Accent
  static const Color _coolGrey = Color(0xFF94A3B8); // Secondary Accent

  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _errorRed = Color(0xFFD32F2F);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF001F3F),
      brightness: Brightness.light,
      primary: _primaryBlue,
      secondary: _secondaryTeal,
      surface: _surfaceLight,
      error: _errorRed,
    ),
    scaffoldBackgroundColor: _backgroundLight,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),

    listTileTheme: const ListTileThemeData(minVerticalPadding: 14, dense: true),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      foregroundColor: Color(0xFFFFFFFF),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _iceBlue,
      brightness: Brightness.dark,
      primary: _iceBlue,
      secondary: _coolGrey,
      surface: _surfaceCold,
      onSurface: Colors.white, // High contrast white
      error: _errorRed,
    ),
    scaffoldBackgroundColor: _backgroundCold,
    // Use white text for professional contrast on dark background
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white),

    listTileTheme: const ListTileThemeData(minVerticalPadding: 14, dense: true),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: _primaryBlue,
      foregroundColor: Color(0xFFFFFFFF),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: _surfaceCold,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  );
}
