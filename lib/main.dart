// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/progress_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/level_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 1️⃣ Base progress provider
        ChangeNotifierProvider(create: (_) => ProgressProvider()),

        // 2️⃣ Quiz provider depends on progress
        ChangeNotifierProxyProvider<ProgressProvider, QuizProvider>(
          create: (context) =>
              QuizProvider(progressProvider: context.read<ProgressProvider>()),
          update: (context, progress, previous) =>
              QuizProvider(progressProvider: progress),
        ),

        // 3️⃣ ✅ Level provider now depends on ProgressProvider
        ChangeNotifierProxyProvider<ProgressProvider, LevelProvider>(
          create: (context) => LevelProvider(context.read<ProgressProvider>()),
          update: (context, progress, previous) => LevelProvider(progress),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Math Arena',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
