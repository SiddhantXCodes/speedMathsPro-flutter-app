// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'services/app_initializer.dart';
import 'services/sync_manager.dart';

// Providers
import 'providers/theme_provider.dart';
import 'providers/practice_log_provider.dart';
import 'providers/performance_provider.dart';
import 'providers/local_user_provider.dart';

// App theme
import 'theme/app_theme.dart';

// Root gate
import 'root_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 App-wide initialization (Hive, Firebase, boxes)
  await AppInitializer.ensureInitialized((_) {});

  // 🔥 Create providers
  final themeProvider = ThemeProvider();
  final practiceProvider = PracticeLogProvider();
  final performanceProvider = PerformanceProvider();
  final localUserProvider = LocalUserProvider();

  // 🔥 Explicit provider initialization
  await Future.wait([
    practiceProvider.init(),
    performanceProvider.init(),
    localUserProvider.init(),
  ]);

  // 🔥 Sync offline data (non-blocking)
  SyncManager().syncPendingSessions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: practiceProvider),
        ChangeNotifierProvider.value(value: performanceProvider),
        ChangeNotifierProvider.value(value: localUserProvider),
      ],
      child: const SpeedMathRootApp(),
    ),
  );
}

///
/// Root MaterialApp wrapper (SINGLE SOURCE OF TRUTH)
///
class SpeedMathRootApp extends StatelessWidget {
  const SpeedMathRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (_, __) {
        final themeProvider = context.watch<ThemeProvider>();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SpeedMath Pro',

          // 🌙 THEME HANDLING (CORRECT PLACE)
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          home: const RootGate(),
        );
      },
    );
  }
}
