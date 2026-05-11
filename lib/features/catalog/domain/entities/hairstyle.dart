class Hairstyle {
  const Hairstyle({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.gender,
    required this.faceShapes,
    required this.imageUrl,
    required this.rating,
    required this.isTrending,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final String difficulty;
  final String gender;
  final List<String> faceShapes;
  final String imageUrl;
  final double rating;
  final bool isTrending;
}
