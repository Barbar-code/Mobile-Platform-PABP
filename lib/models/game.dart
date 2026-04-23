class Game {
  final int id;
  final String title;
  final String genre;
  final String developer;

  Game({
    required this.id,
    required this.title,
    required this.genre,
    required this.developer,
  });

  // Fungsi untuk mengubah JSON dari API menjadi Object Game
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      title: json['title'],
      genre: json['genre'],
      developer: json['developer'],
    );
  }
}