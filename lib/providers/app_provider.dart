// lib/providers/app_provider.dart
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  /// App-level flags (extend later if needed)

  bool _initialized = false;
  bool get initialized => _initialized;

  void markInitialized() {
    if (_initialized) return;
    _initialized = true;
    notifyListeners();
  }
}
