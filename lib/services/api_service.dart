import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  // --- FUNGSI MENGAMBIL TOKEN ---
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // 1. LOGIN
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 2. READ (Ambil Data)
  Future<List<Game>> getGames() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan.');

    final response = await http.get(
      Uri.parse('$baseUrl/api/games'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List games = data['data'];
      return games.map((game) => Game.fromJson(game)).toList();
    } else {
      throw Exception('Gagal mengambil data game.');
    }
  }

  // 3. CREATE (Tambah Data Baru)
  Future<bool> addGame(String title, String genre, String developer) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/games'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'title': title,
        'genre': genre,
        'developer': developer,
      }),
    );
    return response.statusCode == 201;
  }

  // 4. UPDATE (Edit Data)
  Future<bool> updateGame(int id, String title, String genre, String developer) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/games/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'title': title,
        'genre': genre,
        'developer': developer,
      }),
    );
    return response.statusCode == 200;
  }

  // 5. DELETE (Hapus Data)
  Future<bool> deleteGame(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/games/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  // 6. LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}