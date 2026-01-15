// lib/services/app_initializer.dart

import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'hive_boxes.dart';

class AppInitializer {
  static bool _initialized = false;

  static Future<void> ensureInitialized(void Function(String) onStatus) async {
    if (_initialized) return;
    _initialized = true;

    try {
      onStatus("📦 Initializing local storage...");
      await Hive.initFlutter();
      await HiveBoxes.init();

      if (!Hive.isBoxOpen('leaderboard_cache')) {
        await Hive.openBox('leaderboard_cache');
      }

      onStatus("🌐 Connecting leaderboard service...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      onStatus("✅ App ready");
    } catch (e, st) {
      log("Initialization error: $e", stackTrace: st);
      onStatus("❌ Init failed");
    }
  }
}
