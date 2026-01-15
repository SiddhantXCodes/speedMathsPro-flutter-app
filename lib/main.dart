// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'services/app_initializer.dart';
import 'widgets/boot_screen.dart';
import 'services/sync_manager.dart';
import 'app.dart';

// Providers
import 'providers/theme_provider.dart';
import 'providers/practice_log_provider.dart';
import 'providers/performance_provider.dart';
import 'providers/local_user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootApp());
}

class BootApp extends StatefulWidget {
  const BootApp({super.key});

  @override
  State<BootApp> createState() => _BootAppState();
}

class _BootAppState extends State<BootApp> {
  bool _isReady = false;
  String _message = "Initializing…";

  late final ThemeProvider _themeProvider;
  late final PracticeLogProvider _practiceProvider;
  late final PerformanceProvider _performanceProvider;
  late final LocalUserProvider _localUserProvider;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await AppInitializer.ensureInitialized((status) {
        if (mounted) _message = status;
      });

      _themeProvider = ThemeProvider();
      _practiceProvider = PracticeLogProvider();
      _performanceProvider = PerformanceProvider();
      _localUserProvider = LocalUserProvider();

      int retries = 0;
      while ((!_practiceProvider.initialized ||
              !_performanceProvider.initialized ||
              !_localUserProvider.initialized) &&
          retries < 60) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }

      await SyncManager().syncPendingSessions();

      if (mounted) setState(() => _isReady = true);
    } catch (e) {
      if (mounted) _message = "❌ Initialization failed";
    }
  }

  @override
  void dispose() {
    SyncManager().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BootScreen(message: _message),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _themeProvider),
        ChangeNotifierProvider.value(value: _practiceProvider),
        ChangeNotifierProvider.value(value: _performanceProvider),
        ChangeNotifierProvider.value(value: _localUserProvider),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (_, __) => const SpeedMathApp(),
      ),
    );
  }
}
