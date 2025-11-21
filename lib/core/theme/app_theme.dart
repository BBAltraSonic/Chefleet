import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // Glassmorphism tokens
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassWhiteBorder = Color(0x4DFFFFFF);
  static const Color glassDarkBackground = Color(0x33131F16);
  static const Color glassDarkBorder = Color(0x33304739);
  static const double glassBlurSigma = 18.0;

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

  static const TextTheme _textTheme = TextTheme(
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
    titleLarge: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: darkText,
    ),
    titleMedium: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: darkText,
    ),
    titleSmall: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: darkText,
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
    bodySmall: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: darkText,
      height: 1.4,
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
    labelSmall: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: secondaryGreen,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'PlusJakartaSans',
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: secondaryGreen,
      tertiary: surfaceGreen,
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
      color: GlassmorphismTokens.light.background,
      shadowColor: GlassmorphismTokens.light.shadow.first.color,
      elevation: elevation0,
      margin: const EdgeInsets.all(0),
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
    extensions: const [GlassmorphismTokens.light],
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF0D1B12),
    fontFamily: 'PlusJakartaSans',
    visualDensity: VisualDensity.adaptivePlatformDensity,
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
      color: GlassmorphismTokens.dark.background,
      shadowColor: GlassmorphismTokens.dark.shadow.first.color,
      elevation: elevation0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),
    extensions: const [GlassmorphismTokens.dark],
  );

  static BoxDecoration glassBoxDecoration({
    required bool isDark,
    double borderRadius = radiusXLarge,
  }) {
    return BoxDecoration(
      color: isDark ? GlassmorphismTokens.dark.background : GlassmorphismTokens.light.background,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark ? GlassmorphismTokens.dark.border : GlassmorphismTokens.light.border,
        width: 1.2,
      ),
      boxShadow: isDark ? GlassmorphismTokens.dark.shadow : GlassmorphismTokens.light.shadow,
    );
  }

  static GlassmorphismTokens glassTokens(BuildContext context) {
    return Theme.of(context).extension<GlassmorphismTokens>() ?? GlassmorphismTokens.light;
  }

  static const List<String> _fontFiles = [
    'PlusJakartaSans-Regular.ttf',
    'PlusJakartaSans-Medium.ttf',
    'PlusJakartaSans-Bold.ttf',
    'PlusJakartaSans-ExtraBold.ttf',
  ];

  static Future<void> preloadFonts() async {
    final loader = FontLoader('PlusJakartaSans');
    for (final font in _fontFiles) {
      loader.addFont(rootBundle.load('assets/fonts/$font'));
    }
    await loader.load();
  }
}

class GlassmorphismTokens extends ThemeExtension<GlassmorphismTokens> {
  final Color background;
  final Color border;
  final List<BoxShadow> shadow;
  final double blurSigma;
  final double borderRadius;

  const GlassmorphismTokens({
    required this.background,
    required this.border,
    required this.shadow,
    required this.blurSigma,
    required this.borderRadius,
  });

  static const GlassmorphismTokens light = GlassmorphismTokens(
    background: Color(0xCCFFFFFF),
    border: Color(0x4DFFFFFF),
    shadow: [
      BoxShadow(
        color: Color(0x3313EC5B),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
    blurSigma: 18,
    borderRadius: 24,
  );

  static const GlassmorphismTokens dark = GlassmorphismTokens(
    background: Color(0x1A0B140E),
    border: Color(0x3329402F),
    shadow: [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
    blurSigma: 18,
    borderRadius: 24,
  );

  @override
  GlassmorphismTokens copyWith({
    Color? background,
    Color? border,
    List<BoxShadow>? shadow,
    double? blurSigma,
    double? borderRadius,
  }) {
    return GlassmorphismTokens(
      background: background ?? this.background,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      blurSigma: blurSigma ?? this.blurSigma,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  GlassmorphismTokens lerp(ThemeExtension<GlassmorphismTokens>? other, double t) {
    if (other is! GlassmorphismTokens) {
      return this;
    }
    return GlassmorphismTokens(
      background: Color.lerp(background, other.background, t) ?? background,
      border: Color.lerp(border, other.border, t) ?? border,
      shadow: other.shadow,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t) ?? blurSigma,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t) ?? borderRadius,
    );
  }
}