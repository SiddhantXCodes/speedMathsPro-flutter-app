// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'features/performance/performance_provider.dart';
import 'features/practice/practice_log_provider.dart';
import 'theme/app_theme.dart';
import 'features/home/screens/home_screen.dart'; // ✅ moved home to features
import 'services/sync_manager.dart'; // ✅ for future global sync
import 'services/firebase_options.dart'; // optional future use
import 'features/auth/auth_provider.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

/// 🧩 Root Application Widget
class SpeedMathApp extends StatelessWidget {
  const SpeedMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // 🌗 Global Theme
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // 📊 App-wide Data Providers
        ChangeNotifierProvider(
          create: (_) => PerformanceProvider()..loadFromLocal(),
        ),
        ChangeNotifierProvider(create: (_) => PracticeLogProvider()),

        // 🧠 Future: Global app state (sync, network, etc.)
        // ChangeNotifierProvider(create: (_) => AppProvider(syncManager: SyncManager())),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isDark = themeProvider.isDark;

          return AnimatedTheme(
            data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOutCubic,
            child: MaterialApp(
              title: 'SpeedMath Pro',
              debugShowCheckedModeBanner: false,

              themeMode: themeProvider.themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              navigatorObservers: [routeObserver],

              // 🏠 Home Screen
              home: Builder(
                key: ValueKey(isDark), // forces rebuild on theme toggle
                builder: (_) => const HomeScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}
