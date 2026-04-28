import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthResponse? _auth;
  bool _loading = false;
  String? _error;

  AuthResponse? get auth => _auth;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _auth != null;
  bool get isOrganizer => _auth?.role == 'ORGANIZER';
  String get userName => _auth?.name ?? '';
  String get userEmail => _auth?.email ?? '';

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _auth = await _authService.login(email, password);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(
      String name, String email, String password, String role) async {
    _setLoading(true);
    try {
      _auth = await _authService.register(name, email, password, role);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _auth = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
