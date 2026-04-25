import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'game_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  
  // State untuk Menu Library (Visual Demo)
  List<String> _collections = ['Favorite Games'];
  String _activeMenu = 'All Games';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).fetchGames();
    });
  }

  void _navigateToForm({var game}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => GameFormScreen(game: game),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  // Fungsi memunculkan Pop-up Tambah Koleksi Baru
  void _showAddCollectionDialog() {
    TextEditingController collectionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('New Library Collection', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: collectionController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g. RPG Games, Co-op...',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
            onPressed: () {
              if (collectionController.text.isNotEmpty) {
                setState(() {
                  _collections.add(collectionController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Fungsi memunculkan Bottom Sheet untuk memasukkan game ke koleksi
  void _showAddToCollectionSheet(String gameTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add "$gameTitle" to...', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._collections.map((col) => ListTile(
              leading: const Icon(Icons.bookmark_border, color: Colors.deepPurpleAccent),
              title: Text(col, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to $col!')));
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Biar background full menyentuh atas
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar transparan
        elevation: 0,
        title: const Text(
          'IWAKS LibraGame', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1.2, color: Colors.white)
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.power_settings_new, color: Colors.redAccent, size: 28),
              tooltip: 'Logout',
              onPressed: () async {
                await Provider.of<AuthProvider>(context, listen: false).logout();
                if (mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                }
              },
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // --- 1. BACKGROUND FUTURISTIK (Sama seperti Login) ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(top: 100, left: -20, child: Icon(Icons.gamepad, size: 150, color: Colors.white.withOpacity(0.03))),
          Positioned(bottom: 50, right: 100, child: Icon(Icons.sports_esports, size: 200, color: Colors.white.withOpacity(0.03))),

          // --- 2. LAYOUT UTAMA (KIRI MENU, KANAN KONTEN) ---
          SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === PANEL KIRI (SIDEBAR MENU LIBRARY) ===
                Container(
                  width: 250,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 10),
                        child: Text('DASHBOARD', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.apps, color: Colors.white),
                        title: const Text('All Games', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        selected: _activeMenu == 'All Games',
                        selectedTileColor: Colors.deepPurpleAccent.withOpacity(0.3),
                        onTap: () => setState(() => _activeMenu = 'All Games'),
                      ),
                      const Divider(color: Colors.white24, height: 40, indent: 20, endIndent: 20),
                      
                      const Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 10),
                        child: Text('MY LIBRARY', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2)),
                      ),
                      // Daftar Koleksi yang dibuat User
                      Expanded(
                        child: ListView.builder(
                          itemCount: _collections.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.folder, color: Colors.deepPurpleAccent, size: 20),
                              title: Text(_collections[index], style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              onTap: () => setState(() => _activeMenu = _collections[index]),
                            );
                          },
                        ),
                      ),
                      // Tombol Tambah Koleksi
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('New Collection'),
                          onPressed: _showAddCollectionDialog,
                        ),
                      )
                    ],
                  ),
                ),

                // === PANEL KANAN (SEARCH & GAME LIST) ===
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, right: 24, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end, // Meratakan ke kanan
                      children: [
                        // --- SEARCH BAR (Ukuran Sedang, Di Kanan, Font Putih) ---
                        SizedBox(
                          width: 350, // Membatasi lebar Search Bar
                          child: TextField(
                            onChanged: (value) => setState(() => _searchQuery = value),
                            style: const TextStyle(color: Colors.white), // Fix font hitam jadi putih
                            decoration: InputDecoration(
                              hintText: 'Cari judul game...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              prefixIcon: const Icon(Icons.search, color: Colors.deepPurpleAccent),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.5),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Header List
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _activeMenu, 
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
                              icon: const Icon(Icons.add, color: Colors.white, size: 18),
                              label: const Text('Add Game', style: TextStyle(color: Colors.white)),
                              onPressed: () => _navigateToForm(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- DAFTAR GAME ---
                        Expanded(
                          child: Consumer<GameProvider>(
                            builder: (context, gameProvider, child) {
                              if (gameProvider.state == GameState.loading) {
                                return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
                              }
                              
                              final filteredGames = gameProvider.games.where((g) {
                                return g.title.toLowerCase().contains(_searchQuery.toLowerCase());
                              }).toList();

                              if (filteredGames.isEmpty) {
                                return const Center(child: Text('Game tidak ditemukan.', style: TextStyle(color: Colors.grey)));
                              }

                              return ListView.builder(
                                itemCount: filteredGames.length,
                                itemBuilder: (context, index) {
                                  final game = filteredGames[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4), // Glassmorphism card
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 50, height: 50,
                                          color: Colors.deepPurpleAccent.withOpacity(0.2),
                                          child: Center(
                                            child: Text(game.title[0].toUpperCase(), style: const TextStyle(color: Colors.deepPurpleAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                      title: Text(game.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text('${game.genre} • ${game.developer}', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Tombol Tambah ke Koleksi (Fitur Baru)
                                          IconButton(
                                            icon: const Icon(Icons.playlist_add, color: Colors.greenAccent),
                                            tooltip: 'Add to Collection',
                                            onPressed: () => _showAddToCollectionSheet(game.title),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                            onPressed: () => _navigateToForm(game: game),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                                            onPressed: () => gameProvider.deleteGame(game.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}