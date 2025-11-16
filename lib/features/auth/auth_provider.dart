// lib/features/auth/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'auth_repository.dart';
import '../../providers/performance_provider.dart';

/// 🧠 AuthProvider bridges UI and AuthRepository.
class AuthProvider extends ChangeNotifier {
  late final AuthRepository _repo;

  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  bool _loading = false;
  String? _error;
  bool get loading => _loading;
  String? get error => _error;

  /// -------------------------------------------------------------
  /// 🔥 NORMAL CONSTRUCTOR — used in real app
  /// -------------------------------------------------------------
  AuthProvider() {
    _repo = AuthRepository();

    _repo.userChanges.listen((firebaseUser) {
      _user = firebaseUser;
      notifyListeners();
    });
  }

  /// -------------------------------------------------------------
  /// 🧪 TEST CONSTRUCTOR — used only inside Flutter tests
  /// -------------------------------------------------------------
  AuthProvider.test(FirebaseAuth mockAuth) {
    _repo = AuthRepository.test(mockAuth);

    _repo.userChanges.listen((firebaseUser) {
      _user = firebaseUser;
      notifyListeners();
    });
  }

  // --------------------------------------------------------------------------
  // 🔐 LOGIN
  // --------------------------------------------------------------------------
  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    _setLoading(true);
    try {
      await _repo.signInWithEmail(email, password);
      await context.read<PerformanceProvider>().reloadAll();
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  // --------------------------------------------------------------------------
  // 🆕 REGISTER
  // --------------------------------------------------------------------------
  Future<void> register(
    String name,
    String email,
    String password,
    BuildContext context,
  ) async {
    _setLoading(true);
    try {
      await _repo.registerWithEmail(name, email, password);
      await context.read<PerformanceProvider>().reloadAll();
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  // --------------------------------------------------------------------------
  // 🔐 GOOGLE AUTH
  // --------------------------------------------------------------------------
  Future<void> loginWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      await _repo.signInWithGoogle();
      await context.read<PerformanceProvider>().reloadAll();
    } finally {
      _setLoading(false);
    }
  }

  // --------------------------------------------------------------------------
  // 🔐 RESET PASSWORD
  // --------------------------------------------------------------------------
  Future<void> resetPassword(String email) => _repo.sendPasswordReset(email);

  // --------------------------------------------------------------------------
  // 🚪 LOGOUT
  // --------------------------------------------------------------------------
  Future<void> logout(BuildContext context) async {
    context.read<PerformanceProvider>().resetAll();
    await _repo.signOut();
    _user = null;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // INTERNAL
  // --------------------------------------------------------------------------
  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}
