import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/api_service.dart';

// Enum untuk merepresentasikan 3 state (Loading, Success, Error)
enum GameState { loading, loaded, error }

class GameProvider with ChangeNotifier {
  List<Game> _games = [];
  GameState _state = GameState.loading;
  String _errorMessage = '';

  // Getter agar data bisa dibaca oleh UI
  List<Game> get games => _games;
  GameState get state => _state;
  String get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  // Fungsi untuk mengambil data dan merubah state UI
  Future<void> fetchGames() async {
    _state = GameState.loading;
    notifyListeners(); // Perintahkan UI untuk menampilkan animasi muter-muter (loading)

    try {
      _games = await _apiService.getGames();
      _state = GameState.loaded; // Perintahkan UI menampilkan daftar game
    } catch (e) {
      _state = GameState.error; // Perintahkan UI menampilkan pesan error
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    notifyListeners(); // Update layar dengan state yang baru
  }
}