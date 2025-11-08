import 'package:flutter/material.dart';

class AppTheme {
  // -------------------------------
  // 🎨 Color Tokens
  // -------------------------------

  // 🌞 LIGHT MODE — Deep navy-teal elegance
  static const Color lightPrimary = Color(0xFF004D40); // Deep teal-navy
  static const Color lightSecondary = Color(0xFF26A69A); // Calm mint accent
  static const Color lightBackground = Color(0xFFF7FAF9);
  static const Color lightSurface = Colors.white;

  // 🌚 DARK MODE — Refined Royal Sapphire look
  static const Color darkPrimary = Color(0xFF1E88E5); // Clean medium blue
  static const Color darkSecondary = Color(0xFF5EA7F9); // Soft glow sapphire
  static const Color darkBackground = Color(
    0xFF141A22,
  ); // Gentle navy-gray base
  static const Color darkSurface = Color(0xFF1E242C); // Elevated dark card

  // ✍️ Text contrast colors
  static const Color darkTextStrong = Color(0xFFE5EDF5); // Soft bright white
  static const Color darkTextMedium = Color(0xFFB0BEC5); // Dim slate gray-blue

  // 🏅 Rank / Status
  static const Color rankGold = Color(0xFFFFD700);
  static const Color rankSilver = Color(0xFFC0C0C0);
  static const Color rankBronze = Color(0xFFCD7F32);

  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFCA28);
  static const Color danger = Color(0xFFE57373);

  // -------------------------------
  // 🌞 LIGHT THEME
  // -------------------------------
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: false,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: lightPrimary,
      brightness: Brightness.light,
      primary: lightPrimary,
      secondary: lightSecondary,
      surface: lightSurface,
      background: lightBackground,
      onPrimary: Colors.white,
      onSurface: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
      elevation: 0,
    ),
    cardColor: lightSurface,
    iconTheme: const IconThemeData(color: lightPrimary),
    dividerColor: Colors.black12,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: lightSecondary,
    ),
  );

  // -------------------------------
  // 🌚 DARK THEME — Refined glow version
  // -------------------------------
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: darkPrimary,
      onPrimary: Colors.white,
      secondary: darkSecondary,
      onSecondary: Colors.white,
      surface: darkSurface,
      onSurface: darkTextStrong,
      background: darkBackground,
      onBackground: darkTextStrong,
      error: danger,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: darkTextStrong,
      elevation: 0,
      centerTitle: true,
    ),
    cardColor: darkSurface,
    dividerColor: const Color(0xFF27313E),
    iconTheme: const IconThemeData(color: darkPrimary),

    // Buttons (Submit, etc.)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: darkSecondary.withOpacity(0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    // Text Styles
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkTextStrong, fontSize: 16),
      bodyMedium: TextStyle(color: darkTextStrong),
      bodySmall: TextStyle(color: darkTextMedium),
      titleMedium: TextStyle(
        color: darkTextStrong,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: darkTextStrong,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Input / Card fields (like answer options)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: darkSecondary,
    ),
  );

  // -------------------------------
  // 🧠 Helper Utilities
  // -------------------------------
  static Color adaptiveText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color adaptiveCard(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color adaptiveAccent(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color divider(BuildContext context) => Theme.of(context).dividerColor;

  // 🏅 Rank Colors
  static Color get gold => rankGold;
  static Color get silver => rankSilver;
  static Color get bronze => rankBronze;
  static Color get successColor => success;
  static Color get warningColor => warning;
  static Color get dangerColor => danger;
}
