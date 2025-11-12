// lib/main.dart
import 'package:flutter/material.dart';
import 'services/app_initializer.dart';
import 'widgets/boot_screen.dart';
import 'services/sync_manager.dart'; // 🧩 Add this import
import 'app.dart';

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
  String _message = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setState(() => _message = "Starting services...");

      // 🔹 1️⃣ Run your existing app initializer
      await AppInitializer.initialize((status) {
        setState(() => _message = status);
      });

      // 🔹 2️⃣ After initialization, start SyncManager
      SyncManager().start(); // ✅ Automatically watches connectivity and syncs

      // Optional: trigger immediate sync on boot
      await SyncManager().syncPendingSessions();

      // 🔹 3️⃣ Mark app as ready
      setState(() => _isReady = true);
    } catch (e) {
      setState(() => _message = "❌ Initialization failed: $e");
    }
  }

  @override
  void dispose() {
    // 🧹 Stop sync listener when app closes
    SyncManager().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) return BootScreen(message: _message);
    return const SpeedMathApp();
  }
}
