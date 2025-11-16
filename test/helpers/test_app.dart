import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_mocks.dart';

import 'package:speedmaths_pro/app.dart';
import 'package:speedmaths_pro/providers/theme_provider.dart';
import 'package:speedmaths_pro/features/auth/auth_provider.dart';
import 'package:speedmaths_pro/providers/practice_log_provider.dart';
import 'package:speedmaths_pro/providers/performance_provider.dart';

/// -----------------------------------------------------------
/// 🔥 Wrap SpeedMathApp with Providers + mocked Firebase
/// -----------------------------------------------------------
Widget createTestApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(
        create: (_) => AuthProvider(mockAuth, mockGoogleSignIn),
      ),
      ChangeNotifierProvider(create: (_) => PracticeLogProvider()),
      ChangeNotifierProvider(create: (_) => PerformanceProvider()),
    ],
    child: const MaterialApp(home: SpeedMathApp()),
  );
}
