import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_repository.dart';

/// 🧠 AuthProvider bridges UI and AuthRepository.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  User? get user => _repo.currentUser;
  bool get isLoggedIn => user != null;

  Stream<User?> get userStream => _repo.userChanges;

  bool _loading = false;
  String? _error;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _repo.signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      await _repo.registerWithEmail(name, email, password);
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) => _repo.sendPasswordReset(email);

  Future<void> loginWithGoogle() async {
    _setLoading(true);
    try {
      await _repo.signInWithGoogle();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _repo.signOut();
    notifyListeners();
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}
