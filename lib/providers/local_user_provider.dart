import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocalUserProvider extends ChangeNotifier {
  static const _boxName = 'local_user';

  bool _initialized = false;
  String? _username;
  String? _deviceId;

  late Box _box;

  bool get initialized => _initialized;
  String get username => _username ?? "";
  String get deviceId => _deviceId ?? "";

  bool get hasUsername => _username != null && _username!.isNotEmpty;

  LocalUserProvider() {
    _init();
  }

  Future<void> _init() async {
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

  Future<void> setUsername(String name) async {
    final clean = name.trim();

    if (clean.length < 3) {
      throw Exception("Username too short");
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

  String _generateDeviceId() {
    final rnd = Random();
    return List.generate(12, (_) => rnd.nextInt(16).toRadixString(16)).join();
  }
}
