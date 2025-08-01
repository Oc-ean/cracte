import 'dart:async';
import 'package:cracte/src/common/common.dart';
import 'package:hive/hive.dart';

class FavoriteRecipeDataSource {
  final Box<FavouriteRecipe> _favoriteBox;
  final StreamController<List<FavouriteRecipe>> _favoriteRecipeController =
      StreamController<List<FavouriteRecipe>>.broadcast();

  FavoriteRecipeDataSource()
      : _favoriteBox = Hive.box<FavouriteRecipe>('favorite_recipes');

  Future<List<FavouriteRecipe>> getFavorites() async {
    try {
      return _favoriteBox.values.toList();
    } catch (e) {
      logman.error('Failed to load favorite recipes: $e');
      return [];
    }
  }

  Future<void> saveFavorites(List<FavouriteRecipe> favorites) async {
    try {
      await _favoriteBox.clear();
      await _favoriteBox.addAll(favorites);
      _favoriteRecipeController.add(favorites);
    } catch (e) {
      logman.error('Failed to save favorite recipes: $e');
    }
  }

  Future<void> addToFavorites(Recipe recipe) async {
    try {
      final favorites = await getFavorites();
      final alreadyExists = favorites.any((fav) => fav.recipe.id == recipe.id);
      if (alreadyExists) return;

      final now = DateTime.now();
      final updatedFavorites = [
        ...favorites,
        FavouriteRecipe(
          recipe: recipe.copyWith(isFavorite: true),
          dateCreated: now,
          lastModified: now,
        ),
      ];

      await saveFavorites(updatedFavorites);
    } catch (e) {
      logman.error('Failed to add to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String recipeId) async {
    try {
      final favorites = await getFavorites();
      final updated =
          favorites.where((fav) => fav.recipe.id != recipeId).toList();
      await saveFavorites(updated);
    } catch (e) {
      logman.error('Failed to remove from favorites: $e');
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      await _favoriteBox.clear();
      _favoriteRecipeController.add([]);
    } catch (e) {
      logman.error('Failed to clear all favorites: $e');
    }
  }

  Stream<List<FavouriteRecipe>> getFavoriteStream() =>
      _favoriteRecipeController.stream;

  void dispose() {
    _favoriteRecipeController.close();
  }
}
