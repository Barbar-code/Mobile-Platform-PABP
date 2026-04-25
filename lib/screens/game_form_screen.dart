import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../providers/game_provider.dart';

class GameFormScreen extends StatefulWidget {
  final Game? game;

  const GameFormScreen({super.key, this.game});

  @override
  State<GameFormScreen> createState() => _GameFormScreenState();
}

class _GameFormScreenState extends State<GameFormScreen> {
  final _titleController = TextEditingController();
  final _developerController = TextEditingController();
  
  // State untuk Dropdown Genre
  String? _selectedGenre;
  bool _isLoading = false;

  // Daftar lengkap genre game (Bisa di-scroll)
  final List<String> _genreList = [
    'Action', 'Adventure', 'RPG', 'MMORPG', 'Strategy', 'MOBA', 
    'FPS', 'TPS', 'Puzzle', 'Racing', 'Simulation', 'Sports', 
    'Fighting', 'Horror', 'Survival', 'Sandbox', 'Platformer', 
    'Rhythm', 'Visual Novel', 'Gacha', 'Battle Royale', 'Card Game', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Jika mode Edit, isi otomatis form-nya
    if (widget.game != null) {
      _titleController.text = widget.game!.title;
      _developerController.text = widget.game!.developer;
      
      // Mengecek apakah genre dari database ada di dalam daftar dropdown kita
      if (_genreList.contains(widget.game!.genre)) {
        _selectedGenre = widget.game!.genre;
      } else {
        _selectedGenre = 'Other'; // Default kalau genre lama tidak dikenali
      }
    }
  }

  Future<void> _saveData() async {
    // Validasi form agar tidak kosong
    if (_titleController.text.isEmpty || _selectedGenre == null || _developerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua data!', style: TextStyle(color: Colors.white))),
      );
      return;
    }

    setState(() => _isLoading = true);
    final provider = Provider.of<GameProvider>(context, listen: false);
    bool success;

    if (widget.game == null) {
      success = await provider.addGame(
        _titleController.text,
        _selectedGenre!,
        _developerController.text,
      );
    } else {
      success = await provider.updateGame(
        widget.game!.id,
        _titleController.text,
        _selectedGenre!,
        _developerController.text,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.game == null ? 'Game berhasil ditambahkan!' : 'Game berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Biar background full menyentuh atas
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Tombol back warna putih
        title: Text(
          widget.game == null ? 'Tambah Game' : 'Edit Game', 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
      ),
      body: Stack(
        children: [
          // --- 1. BACKGROUND FUTURISTIK ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(top: 150, right: -20, child: Icon(Icons.gamepad, size: 180, color: Colors.white.withOpacity(0.05))),
          Positioned(bottom: 80, left: -30, child: Icon(Icons.videogame_asset, size: 150, color: Colors.white.withOpacity(0.05))),

          // --- 2. FORM KOTAK TENGAH (UKURAN DIPERKECIL) ---
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 450, // Membatasi lebar form agar tidak full layar
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6), // Efek Kaca
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.deepPurpleAccent.withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ikon Header Kotak
                    const Icon(Icons.add_to_queue, size: 50, color: Colors.deepPurpleAccent),
                    const SizedBox(height: 24),

                    // Input Judul
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Judul Game',
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.title, color: Colors.deepPurpleAccent),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Genre (DIUBAH JADI DROPDOWN MENU)
                    DropdownButtonFormField<String>(
                      value: _selectedGenre,
                      dropdownColor: const Color(0xFF1E1E1E), // Warna background dropdown saat terbuka
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Genre',
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.category, color: Colors.deepPurpleAccent),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: _genreList.map((String genre) {
                        return DropdownMenuItem<String>(
                          value: genre,
                          child: Text(genre),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGenre = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input Developer
                    TextField(
                      controller: _developerController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Developer',
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.business, color: Colors.deepPurpleAccent),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _saveData,
                              child: const Text(
                                'SIMPAN GAME',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}