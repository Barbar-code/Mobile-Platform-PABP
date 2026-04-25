import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      // Kita tidak pakai AppBar agar background bisa full screen
      body: Stack(
        children: [
          // --- 1. BACKGROUND FUTURISTIK & GAMING ELEMENTS ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], 
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Elemen Gaming transparan berserakan di background
          Positioned(
            top: 50, left: -20,
            child: Icon(Icons.gamepad, size: 150, color: Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            bottom: 100, right: -30,
            child: Icon(Icons.sports_esports, size: 200, color: Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            top: 200, right: 50,
            child: Icon(Icons.track_changes, size: 100, color: Colors.white.withOpacity(0.05)), // Tanda Aim
          ),
          Positioned(
            bottom: -20, left: 80,
            child: Icon(Icons.mouse, size: 120, color: Colors.white.withOpacity(0.05)),
          ),

          // --- 2. KOTAK LOGIN DI TENGAH (CENTERED) ---
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(32.0),
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6), // Efek kaca gelap
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Icon & Judul Baru
                    const Icon(Icons.videogame_asset, size: 60, color: Colors.deepPurpleAccent),
                    const SizedBox(height: 16),
                    const Text(
                      'IWAKS LibraGame',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'System Login Portal',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 36),

                    // Input Username
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.person, color: Colors.deepPurpleAccent),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Password
                    TextField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: true, // Sensor password
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.lock, color: Colors.deepPurpleAccent),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pesan Error (kalau login salah)
                    if (authProvider.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          authProvider.errorMessage,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ),

                    // Tombol Login
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: authProvider.isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              onPressed: () async {
                                bool success = await authProvider.login(
                                  _usernameController.text,
                                  _passwordController.text,
                                );
                                if (success && context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                                  );
                                }
                              },
                              child: const Text(
                                'START ENGINE', // Kata-kata ala gaming
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
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