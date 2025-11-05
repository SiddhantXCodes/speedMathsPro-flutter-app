import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Brand & accent colors
  static const MaterialAccentColor lightAccent = Colors.blueAccent;

  // Softer blue-teal for dark mode (eye-comfort optimized)
  static const MaterialAccentColor darkTealAccent = MaterialAccentColor(
    0xFF64B5F6, // main tone
    <int, Color>{
      100: Color(0xFF4FC3F7),
      200: Color(0xFF29B6F6),
      400: Color(0xFF039BE5),
      700: Color(0xFF0288D1),
    },
  );

  // Neutral backgrounds
  static const Color lightBackground = Color(0xFFF8F9FB);
  static const Color darkBackground = Color(0xFF121212);

  // Core brand color (used for app bars and highlights)
  static const Color primaryColor = Colors.deepPurple;

  // -------------------------------
  // LIGHT THEME
  // -------------------------------
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: false,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: lightAccent,
      surface: Colors.white,
      background: lightBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: Colors.white,
    iconTheme: IconThemeData(color: lightAccent.shade200),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightAccent,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
  );

  // -------------------------------
  // DARK THEME
  // -------------------------------
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.dark(
      primary: darkTealAccent,
      secondary: darkTealAccent,
      surface: const Color(0xFF1E1E1E),
      background: darkBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: const Color(0xFF1E1E1E),
    iconTheme: IconThemeData(color: darkTealAccent.shade200),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkTealAccent,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
  );

  // -------------------------------
  // Helper utilities
  // -------------------------------
  static Color adaptiveText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.black87;
  }

  static Color adaptiveCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E1E1E) : Colors.white;
  }

  static Color adaptiveAccent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTealAccent : lightAccent;
  }

  static Color divider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white24 : Colors.black12;
  }
}
