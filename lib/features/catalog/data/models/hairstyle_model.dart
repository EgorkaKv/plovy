import 'package:plovy/features/catalog/domain/entities/hairstyle.dart';

class HairstyleModel extends Hairstyle {
  const HairstyleModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.difficulty,
    required super.gender,
    required super.faceShapes,
    required super.imageUrl,
    required super.rating,
    required super.isTrending,
  });

  factory HairstyleModel.fromJson(Map<String, dynamic> json) => HairstyleModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        difficulty: json['difficulty'] as String,
        gender: json['gender'] as String,
        faceShapes: (json['faceShapes'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        imageUrl: json['imageUrl'] as String,
        rating: (json['rating'] as num).toDouble(),
        isTrending: json['isTrending'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'difficulty': difficulty,
        'gender': gender,
        'faceShapes': faceShapes,
        'imageUrl': imageUrl,
        'rating': rating,
        'isTrending': isTrending,
      };
}
