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

  // 🌚 DARK MODE — Soft Sapphire Light+ (balanced glow)
  // Hybrid accent idea:
  static const Color darkPrimary = Color(0xFF3FA7D6); // Sapphire teal-blue
  static const Color darkSecondary = Color(0xFF81C3F2); // Soft cool glow

  static const Color darkBackground = Color(0xFF1E2532); // Soft navy-gray
  static const Color darkSurface = Color(0xFF27313F); // Slightly lifted surface

  // ✍️ Text contrast colors (brighter now)
  static const Color darkTextStrong = Color(0xFFF3F7FC); // Brighter white
  static const Color darkTextMedium = Color(0xFFC9D4DD); // Softer gray-blue

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
  // 🌚 DARK THEME — Soft Sapphire Light+ variant
  // -------------------------------
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      surface: darkSurface,
      background: darkBackground,
      error: danger,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextStrong,
      onBackground: darkTextStrong,
      onError: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: darkTextStrong,
      elevation: 0,
      centerTitle: true,
    ),

    cardColor: darkSurface,
    dividerColor: Color(0xFF2E3A4A),

    iconTheme: const IconThemeData(color: darkPrimary),

    // 🔘 Elevated Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: darkSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    // 📝 Text Styles — brighter & clearer
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkTextStrong, fontSize: 16, height: 1.5),
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

    // 🧾 Input / Card Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface.withOpacity(0.95),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    // ✍️ Cursor / Selection
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
