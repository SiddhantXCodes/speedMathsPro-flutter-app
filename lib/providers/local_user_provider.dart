import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocalUserProvider extends ChangeNotifier {
  static const _boxName = 'local_user';

  bool _initialized = false;
  String? _username;
  String? _deviceId;

  late Box _box;

  // -------------------------
  // GETTERS
  // -------------------------

  bool get isInitialized => _initialized;
  bool get hasUsername => _username != null && _username!.isNotEmpty;

  String get username => _username ?? "";
  String get deviceId => _deviceId ?? "";

  // -------------------------
  // INIT (CALL ON APP START)
  // -------------------------

  Future<void> init() async {
    if (_initialized) return; // 🔐 safety

    _box = await Hive.openBox(_boxName);

    _username = _box.get('username');
    _deviceId = _box.get('device_id');

    if (_deviceId == null) {
      _deviceId = _generateDeviceId();
      await _box.put('device_id', _deviceId);
    }

    _initialized = true;
    notifyListeners();
  }

  // -------------------------
  // USERNAME ACTIONS
  // -------------------------

  Future<void> setUsername(String name) async {
    final clean = name.trim();

    if (clean.length < 3) {
      throw Exception("Username must be at least 3 characters");
    }

    _username = clean;
    await _box.put('username', clean);

    notifyListeners();
  }

  Future<void> clearUsername() async {
    _username = null;
    await _box.delete('username');

    notifyListeners();
  }

  // -------------------------
  // INTERNAL HELPERS
  // -------------------------

  String _generateDeviceId() {
    final rnd = Random();
    return List.generate(
      12,
      (_) => rnd.nextInt(16).toRadixString(16),
    ).join();
  }
}
