import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';

class ApiService {
  // Karena kita akan tes di Web (Chrome), kita bisa langsung pakai localhost
  static const String baseUrl = 'http://localhost:3000';

  // 1. Fungsi Login & Simpan Token
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Simpan token JWT ke memori lokal
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Error saat login: $e');
      return false;
    }
  }

  // 2. Fungsi Ambil Data Game (Wajib pakai Token)
  Future<List<Game>> getGames() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    // Jika tidak ada token, tolak akses
    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login kembali.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/games'),
      headers: {
        'Authorization': 'Bearer $token', // Menempelkan token di header
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List games = data['data']; // Mengambil array dari dalam properti 'data'
      return games.map((game) => Game.fromJson(game)).toList();
    } else {
      throw Exception('Gagal mengambil data game dari server.');
    }
  }

  // 3. Fungsi Logout (Hapus Token)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}