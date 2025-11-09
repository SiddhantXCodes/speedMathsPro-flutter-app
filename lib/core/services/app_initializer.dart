import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../firebase/firebase_options.dart';
import '../services/hive_boxes.dart';
import '../sync/sync_manager.dart';

/// ✅ Handles initialization of Firebase, Hive, and SyncManager.
/// Used during app startup (BootScreen or main).
class AppInitializer {
  static Future<void> initialize(void Function(String) onStatus) async {
    try {
      // --------------------------------------------------------
      // 🔹 Firebase Initialization
      // --------------------------------------------------------
      onStatus("⚙️ Connecting to Firebase...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      log("✅ Firebase initialized successfully");

      // --------------------------------------------------------
      // 🔹 Hive Initialization + Adapter Registration
      // --------------------------------------------------------
      onStatus("📦 Setting up local storage...");
      await HiveBoxes.init();
      log("✅ Hive initialized and adapters registered");

      // --------------------------------------------------------
      // 🔹 Leaderboard Cache (Optional)
      // --------------------------------------------------------
      if (!Hive.isBoxOpen('leaderboard_cache')) {
        await Hive.openBox('leaderboard_cache');
        log("✅ Leaderboard cache box opened");
      }

      // --------------------------------------------------------
      // 🔹 Sync Manager
      // --------------------------------------------------------
      onStatus("🔄 Starting background sync...");
      SyncManager().start();
      log("🔁 SyncManager started and listening for connectivity changes");

      // --------------------------------------------------------
      // ✅ Final Step
      // --------------------------------------------------------
      onStatus("✅ Setup complete — Ready to launch!");
      log("🚀 App initialization complete!");
    } catch (e, st) {
      log("❌ App initialization failed: $e", stackTrace: st);
      onStatus("❌ Initialization failed — please restart the app.");
    }
  }
}
