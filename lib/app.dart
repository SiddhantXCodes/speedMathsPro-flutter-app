import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/performance_provider.dart';
import 'providers/practice_log_provider.dart';
import 'theme/app_theme.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }
}

class SpeedMathApp extends StatelessWidget {
  const SpeedMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => PerformanceProvider()..loadFromStorage(),
        ),
        ChangeNotifierProvider(create: (_) => PracticeLogProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final themeMode = themeProvider.themeMode;

          return AnimatedTheme(
            data: themeMode == ThemeMode.dark
                ? AppTheme.darkTheme
                : AppTheme.lightTheme,
            // 💡 Change this to 200ms if you want a *smooth fade* instead
            duration: Duration.zero, // ✅ Instant theme change
            child: MaterialApp(
              title: 'SpeedMath',
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              navigatorObservers: [routeObserver],
              home: const HomeScreen(),
            ),
          );
        },
      ),
    );
  }
}
