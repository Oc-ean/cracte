import 'package:hive/hive.dart';
import 'package:cracte/src/common/common.dart';
part 'favourite_recipe.g.dart';

@HiveType(typeId: 3)
class FavouriteRecipe {
  @HiveField(0)
  final Recipe recipe;
  @HiveField(1)
  final DateTime dateCreated;
  @HiveField(2)
  final DateTime lastModified;

  FavouriteRecipe({
    required this.recipe,
    required this.dateCreated,
    required this.lastModified,
  });

  factory FavouriteRecipe.fromJson(Map<String, dynamic> json) {
    final recipeId = json['recipe']['id'] as String;
    return FavouriteRecipe(
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>, recipeId),
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'recipe': recipe.toJson(),
        'dateCreated': dateCreated.toIso8601String(),
        'lastModified': lastModified.toIso8601String(),
      };
}
