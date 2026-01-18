import 'dart:async';

import 'package:cracte/src/common/common.dart';
import 'package:hive/hive.dart';

class RecipeDataSource {
  final Box<Recipe> _recipeBox;
  final StreamController<List<Recipe>> recipeController =
      StreamController<List<Recipe>>.broadcast();

  RecipeDataSource() : _recipeBox = Hive.box<Recipe>('recipes');

  Future<List<Recipe>> getRecipes() async {
    try {
      final recipes = _recipeBox.values.toList();
      return recipes;
    } catch (e) {
      logman.error('Failed to get recipes: $e');
      return [];
    }
  }

  Future<void> saveRecipes(List<Recipe> recipes) async {
    try {
      await _recipeBox.clear();
      await _recipeBox.addAll(recipes);
      recipeController.add(recipes);
    } catch (e) {
      logman.error('Failed to save recipes: $e');
    }
  }

  Future<void> updateRecipe(Recipe updatedRecipe) async {
    try {
      final recipes = _recipeBox.values.toList();
      final index = recipes.indexWhere((r) => r.id == updatedRecipe.id);

      if (index != -1) {
        final updatedRecipeWithTimestamp = updatedRecipe.copyWith(
          updatedAt: DateTime.now(),
        );

        await _recipeBox.putAt(index, updatedRecipeWithTimestamp);

        recipes[index] = updatedRecipeWithTimestamp;
        recipeController.add(recipes);
      }
    } catch (e) {
      logman.error('Failed to update recipe: $e');
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      final recipes = _recipeBox.values.toList();
      final index = recipes.indexWhere((r) => r.id == id);

      if (index != -1) {
        await _recipeBox.deleteAt(index);
        recipes.removeAt(index);
        recipeController.add(recipes);
      }
    } catch (e) {
      logman.error('Failed to delete recipe: $e');
    }
  }

  Stream<List<Recipe>> getRecipesStream() => recipeController.stream;

  void dispose() {
    recipeController.close();
  }
}
