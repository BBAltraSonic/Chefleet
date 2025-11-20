import 'package:flutter/material.dart';
import 'dart:ui';

class AppTheme {
  static const Color backgroundColor = Color(0xFFF8FCF9);
  static const Color primaryGreen = Color(0xFF13EC5B);
  static const Color darkText = Color(0xFF0D1B12);
  static const Color secondaryGreen = Color(0xFF4C9A66);
  static const Color surfaceGreen = Color(0xFFE7F3EB);
  static const Color borderGreen = Color(0xFFCFE7D7);
  static const Color modalOverlay = Color(0x66141414);

  static const Color surfaceColor = Color(0x1AFFFFFF);
  static const Color surfaceColorDark = Color(0x0D000000);

  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x1A1A1A1A);

  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;

  static TextTheme _textTheme = const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: darkText,
      height: 1.2,
      letterSpacing: -0.015,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: darkText,
      height: 1.2,
      letterSpacing: -0.015,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: darkText,
      height: 1.2,
      letterSpacing: -0.015,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: darkText,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: secondaryGreen,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: darkText,
      letterSpacing: 0.015,
    ),
    labelMedium: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: darkText,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'PlusJakartaSans',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: secondaryGreen,
      surface: surfaceGreen,
      background: backgroundColor,
      brightness: Brightness.light,
    ),
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: darkText,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.015,
      ),
      iconTheme: IconThemeData(color: darkText, size: 24),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryGreen,
      unselectedItemColor: secondaryGreen,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: darkText,
      elevation: 0,
      shape: CircleBorder(),
    ),
    cardTheme: CardThemeData(
      color: surfaceGreen,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: darkText,
        elevation: 0,
        minimumSize: const Size(84, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.015,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkText,
        side: const BorderSide(color: borderGreen, width: 1),
        elevation: 0,
        minimumSize: const Size(84, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceGreen,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: const BorderSide(color: borderGreen, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: const BorderSide(color: borderGreen, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF0D1B12),
    fontFamily: 'PlusJakartaSans',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: secondaryGreen,
      surface: const Color(0xFF1A2821),
      background: const Color(0xFF0D1B12),
      brightness: Brightness.dark,
    ),
    textTheme: _textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D1B12),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.015,
      ),
      iconTheme: IconThemeData(color: Colors.white, size: 24),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryGreen,
      unselectedItemColor: secondaryGreen,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: darkText,
      elevation: 0,
      shape: CircleBorder(),
    ),
    cardTheme: CardThemeData(
      color: glassDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),
  );
}