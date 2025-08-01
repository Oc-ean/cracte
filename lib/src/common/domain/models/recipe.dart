import 'package:cracte/src/common/common.dart';

import 'package:hive/hive.dart';
part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String image;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final List<String> ingredients;
  @HiveField(5)
  final List<String> steps;
  @HiveField(6)
  final String authorId;
  @HiveField(7)
  final String authorName;
  @HiveField(8)
  final String authorImage;
  @HiveField(9)
  final int duration;
  @HiveField(10)
  final Category category;
  @HiveField(11)
  final bool? isFavorite;
  @HiveField(12)
  final DateTime createdAt;
  @HiveField(13)
  final DateTime updatedAt;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.authorId,
    required this.authorName,
    required this.authorImage,
    required this.duration,
    required this.category,
     this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? image,
    String? description,
    List<String>? ingredients,
    List<String>? steps,
    String? authorId,
    String? authorName,
    String? authorImage,
    int? duration,
    Category? category,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorImage: authorImage ?? this.authorImage,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'authorId': authorId,
      'authorName': authorName,
      'authorImage': authorImage,
      'duration': duration,
      'category': category.toJson(),
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool isEqualTo(Recipe other) {
    return id == other.id &&
        title == other.title &&
        description == other.description &&
        image == other.image &&
        authorId == other.authorId &&
        authorName == other.authorName &&
        authorImage == other.authorImage &&
        _listEquals(ingredients, other.ingredients) &&
        _listEquals(steps, other.steps);
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  factory Recipe.fromJson(Map<String, dynamic> json, String documentId) {
    final categoryJson = json['category'] as Map<String, dynamic>;
    final categoryId = categoryJson['id'] as String;
    return Recipe(
      id: documentId,
      title: json['title'] as String,
      image: json['image'] as String,
      description: json['description'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      steps: List<String>.from(json['steps'] as List),
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorImage: json['authorImage'] as String,
      duration: json['duration'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      category: Category.fromJson(
        json['category'] as Map<String, dynamic>,
        categoryId,
      ),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  factory Recipe.sampleData() {
    final now = DateTime.now();
    return Recipe(
      id: 'b1',
      title: 'Pancakes',
      image: 'https://images.pexels.com/photos/718739/pexels-photo-718739.jpeg',
      description: 'Fluffy pancakes served with syrup.',
      ingredients: ['Flour', 'Eggs', 'Milk', 'Baking powder', 'Sugar'],
      steps: [
        'Mix ingredients to form batter.',
        'Cook on a hot pan until golden.',
      ],
      authorId: 'u1',
      authorName: 'Emily Clark',
      authorImage: 'https://randomuser.me/api/portraits/women/1.jpg',
      duration: 15,
      category: Category.sampleData(),
      isFavorite: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}
