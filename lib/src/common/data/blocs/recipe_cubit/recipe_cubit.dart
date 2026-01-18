import 'dart:async';

import 'package:cracte/src/common/common.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final RecipeRepository repository;
  final CategoryRepository categoryRepository;

  StreamSubscription<List<Recipe>>? _recipeSubscription;

  RecipeCubit({required this.repository, required this.categoryRepository})
      : super(RecipeInitial()) {
    saveDefaultRecipes();
    _subscribeToRecipes();
  }

  Future<void> saveDefaultRecipes() async {
    try {
      
      final existing = await repository.getRecipes();
      if (existing.isEmpty) {
        await repository.saveDefaultRecipes(recipes);
      }
      await getRecipes();
    } catch (e) {
      logman.error('Failed to save default recipes: $e');
      emit(const RecipeError('Failed to save default recipes'));
    }
  }

  void _subscribeToRecipes() {
    _recipeSubscription?.cancel();

    _recipeSubscription = repository.recipesStream.listen(
      (loadedRecipes) {
        try {
          if (loadedRecipes.isEmpty && repository.totalRecipes == 0) {
            emit(RecipeEmpty());
            return;
          }

          const limit = 10;
          final currentPage = repository.currentPage;
          final totalPages = (repository.totalRecipes / limit).ceil();

          emit(
            RecipeLoaded(
              recipes: loadedRecipes,
              page: currentPage,
              totalPages: totalPages,
            ),
          );
        } catch (e) {
          logman.error('Error processing recipe stream: $e');
          emit(const RecipeError('Failed to process recipes'));
        }
      },
      onError: (Object error) {
        logman.error('Recipe stream error: $error');
        emit(const RecipeError('Failed to load recipes'));
      },
    );
  }

  Future<void> getRecipes({int limit = 10, bool refresh = false}) async {
    // Only show loading for initial load, not for refresh
    if (!refresh && state is! RecipeLoaded && state is! RecipeLoading) {
      emit(RecipeLoading());
    }

    try {
      await repository.fetchPaginatedRecipes(
          page: 1, limit: limit, refresh: refresh);
    } catch (e) {
      logman.error('Failed to get recipes: $e');
      emit(const RecipeError('Failed to load recipes'));
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await repository.addRecipe(recipe);
      // Repository handles pagination reset, no need to manually fetch here
    } catch (e) {
      logman.error('Failed to add recipe: $e');
      emit(const RecipeError('Failed to add recipe'));
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await repository.updateRecipe(recipe);
      // Repository handles the update and state emission
    } catch (e) {
      logman.error('Failed to update recipe: $e');
      emit(const RecipeError('Failed to update recipe'));
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await repository.deleteRecipe(id);
      // Repository handles pagination adjustment
    } catch (e) {
      logman.error('Failed to delete recipe: $e');
      emit(const RecipeError('Failed to delete recipe'));
    }
  }

  Future<void> fetchMoreRecipes({int limit = 10}) async {
    if (state is! RecipeLoaded) return;

    final previousState = state as RecipeLoaded;

    // Check if we have more pages to load
    if (!repository.hasMorePages) {
      return;
    }

    final nextPage = previousState.page + 1;

    // Emit loading state for pagination
    emit(
      RecipeLoaded(
        recipes: previousState.recipes,
        page: previousState.page,
        totalPages: previousState.totalPages,
        isPaginating: true,
      ),
    );

    try {
      await repository.fetchPaginatedRecipes(page: nextPage, limit: limit);
      // The stream will emit the new state automatically
    } catch (e) {
      logman.error('Failed to paginate recipes: $e');

      // Restore previous state on error
      emit(
        RecipeLoaded(
          recipes: previousState.recipes,
          page: previousState.page,
          totalPages: previousState.totalPages,
        ),
      );
    }
  }

  Future<void> refreshRecipes() async {
    await getRecipes(refresh: true);
  }

  @override
  Future<void> close() {
    _recipeSubscription?.cancel();
    return super.close();
  }
}
