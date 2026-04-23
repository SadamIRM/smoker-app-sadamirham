import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? user;
  String? jwtToken;
  bool isLoading = false;
  String? error;

  Future<void> register(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      await _authService.register(email, password);
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
      jwtToken = await _authService.login(email, password);
      user = FirebaseAuth.instance.currentUser;
      error = null;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    jwtToken = null;
    notifyListeners();
  }
}
