import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? user;
  bool isLoading = false;
  String? error;

  Future<void> register(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await _authService.register(email, password);
      error = null;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await _authService.login(email, password);
      error = null;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  void logout() async {
    await _authService.logout();
    user = null;
    notifyListeners();
  }
}
