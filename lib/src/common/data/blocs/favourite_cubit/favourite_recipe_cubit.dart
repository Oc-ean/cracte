import 'package:cracte/src/common/common.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'favourite_recipe_state.dart';

class FavouriteRecipeCubit extends Cubit<List<FavouriteRecipe>> {
  final FavoriteRecipeDataSource _favouriteDataSource;
  final RecipeDataSource _recipeDataSource;

  FavouriteRecipeCubit({
    required FavoriteRecipeDataSource favouriteDataSource,
    required RecipeDataSource recipeDataSource,
  })  : _favouriteDataSource = favouriteDataSource,
        _recipeDataSource = recipeDataSource,
        super([]) {
    _listenToFavourites();
    _initializeFavourites();
  }

  Future<void> _initializeFavourites() async {
    try {
      final favorites = await _favouriteDataSource.getFavorites();
      emit(favorites);
    } catch (e) {
      logman.error('Failed to initialize favorites: $e');
    }
  }

  void _listenToFavourites() {
    _favouriteDataSource.getFavoriteStream().listen((favorites) {
      emit(favorites);
    });
  }

  Future<void> addFavourite(Recipe recipe) async {
    await _favouriteDataSource.addToFavorites(recipe);

    final updatedRecipe = recipe.copyWith(isFavorite: true);
    await _recipeDataSource.updateRecipe(updatedRecipe);
  }

  Future<void> removeFavourite(Recipe recipe) async {
    await _favouriteDataSource.removeFromFavorites(recipe.id);

    final updatedRecipe = recipe.copyWith(isFavorite: false);
    await _recipeDataSource.updateRecipe(updatedRecipe);
  }

  Future<void> clearFavorites() async {
    final currentFavorites = state;

    await _favouriteDataSource.clearAllFavorites();

    for (final favoriteRecipe in currentFavorites) {
      final updatedRecipe = favoriteRecipe.recipe.copyWith(isFavorite: false);
      await _recipeDataSource.updateRecipe(updatedRecipe);
    }
  }
}
