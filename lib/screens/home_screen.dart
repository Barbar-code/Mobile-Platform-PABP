import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Menjalankan fungsi ambil data segera setelah layar ini dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).fetchGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          // --- IMPLEMENTASI 3-STATE UI ---
          
          // STATE 1: LOADING
          if (gameProvider.state == GameState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // STATE 2: ERROR
          if (gameProvider.state == GameState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(gameProvider.errorMessage),
                  ElevatedButton(
                    onPressed: () => gameProvider.fetchGames(),
                    child: const Text('Coba Lagi'),
                  )
                ],
              ),
            );
          }
          
          // STATE 3: DATA BERHASIL DITAMPILKAN
          return ListView.builder(
            itemCount: gameProvider.games.length,
            itemBuilder: (context, index) {
              final game = gameProvider.games[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text(game.title[0])), // Inisial game
                  title: Text(game.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${game.genre} • ${game.developer}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}