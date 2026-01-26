import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primaryBlue = Color(0xFF1E88E5); // Vibrant Blue
  static const Color _secondaryTeal = Color(0xFF42A5F5); // Light Blue
  static const Color _backgroundLight = Color(0xFFF5F7FA); // Cool Grey/White

  // Cold Blue Palette (Dark Mode)
  static const Color _backgroundCold = Color(0xFF0F172A); // Deep Slate
  static const Color _surfaceCold = Color(0xFF1E293B); // Dark Slate
  static const Color _iceBlue = Color(0xFF38BDF8); // Primary Accent
  static const Color _coolGrey = Color(0xFF94A3B8); // Secondary Accent

  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _errorRed = Color(0xFFD32F2F);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 157, 203, 243),
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
      backgroundColor: _backgroundLight,
      foregroundColor: _primaryBlue,
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
      backgroundColor: _backgroundCold,
      foregroundColor: _iceBlue,
    ),
    cardTheme: CardThemeData(
      color: _surfaceCold,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  );
}
