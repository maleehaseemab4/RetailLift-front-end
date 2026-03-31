// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primaryBlue = Color(0xFF001F3F);
  static const Color _secondaryTeal = Color(0xFF003366);
  static const Color _backgroundLight = Color(0xFFF5F7FA);

  static const Color _backgroundCold = Color(0xFF07091D);
  static const Color _surfaceCold = Color(0xFF111435);
  static const Color _iceBlue = Color(0xFF4DA8DA);
  static const Color _coolGrey = Color(0xFF94A3B8);

  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _errorRed = Color(0xFFD32F2F);

  // Dark gradient: very dark midnight navy → deep indigo → rich purple
  // Matches the reference cyber-AI UI (top-left navy to bottom-right purple)
  static const Color gradientStart = Color(0xFF07091D);
  static const Color gradientEnd = Color(0xFF160838);

  static const BoxDecoration darkGradientBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [gradientStart, Color(0xFF0B0D2E), gradientEnd],
      stops: [0.0, 0.45, 1.0],
    ),
  );

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
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: _surfaceLight,
      foregroundColor: _primaryBlue,
      iconTheme: const IconThemeData(color: _primaryBlue),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _primaryBlue,
      ),
    ),
    iconTheme: const IconThemeData(color: _primaryBlue),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: _primaryBlue),
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
      onSurface: Colors.white,
      error: _errorRed,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white),

    listTileTheme: const ListTileThemeData(minVerticalPadding: 14, dense: true),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
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
