import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/api_service.dart';

enum GameState { loading, loaded, error }

class GameProvider with ChangeNotifier {
  List<Game> _games = [];
  GameState _state = GameState.loading;
  String _errorMessage = '';

  List<Game> get games => _games;
  GameState get state => _state;
  String get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  // READ
  Future<void> fetchGames() async {
    _state = GameState.loading;
    notifyListeners();
    try {
      _games = await _apiService.getGames();
      _state = GameState.loaded;
    } catch (e) {
      _state = GameState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  // CREATE
  Future<bool> addGame(String title, String genre, String developer) async {
    bool success = await _apiService.addGame(title, genre, developer);
    if (success) await fetchGames(); // Refresh data otomatis jika sukses
    return success;
  }

  // UPDATE
  Future<bool> updateGame(int id, String title, String genre, String developer) async {
    bool success = await _apiService.updateGame(id, title, genre, developer);
    if (success) await fetchGames();
    return success;
  }

  // DELETE
  Future<bool> deleteGame(int id) async {
    bool success = await _apiService.deleteGame(id);
    if (success) await fetchGames();
    return success;
  }
}