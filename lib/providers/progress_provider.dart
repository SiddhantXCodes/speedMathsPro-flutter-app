import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider extends ChangeNotifier {
  int highestLevel = 1;
  int coins = 0;
  bool _loaded = false;

  ProgressProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    highestLevel = prefs.getInt('highestLevel') ?? 1;
    coins = prefs.getInt('coins') ?? 0;
    _loaded = true;
    notifyListeners();
  }

  Future<void> unlockNextLevel(int levelCleared, int rewardCoins) async {
    final prefs = await SharedPreferences.getInstance();
    if (levelCleared >= highestLevel) {
      highestLevel = levelCleared + 1;
      await prefs.setInt('highestLevel', highestLevel);
    }
    coins += rewardCoins;
    await prefs.setInt('coins', coins);
    notifyListeners();
  }

  Future<void> addCoins(int c) async {
    final prefs = await SharedPreferences.getInstance();
    coins += c;
    await prefs.setInt('coins', coins);
    notifyListeners();
  }
}
