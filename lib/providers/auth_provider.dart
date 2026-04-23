import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Tampilkan efek loading di tombol login

    bool success = await _apiService.login(username, password);

    if (!success) {
      _errorMessage = 'Username atau password salah!';
    }

    _isLoading = false;
    notifyListeners(); // Matikan efek loading
    return success;
  }

  Future<void> logout() async {
    await _apiService.logout();
    notifyListeners();
  }
}