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
      const RecipeError('Failed to save default recipes');
    }
  }

  void _subscribeToRecipes() {
    _recipeSubscription?.cancel();

    _recipeSubscription = repository.recipesStream.listen(
      (pageRecipes) {
        try {
          if (pageRecipes.isEmpty) {
            emit(RecipeEmpty());
            return;
          }

          const limit = 10;
          final currentPage = (pageRecipes.length / limit).ceil();

          final totalPages = (repository.totalRecipes / limit).ceil();

          emit(
            RecipeLoaded(
              recipes: pageRecipes,
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

  Future<void> getRecipes({int limit = 10}) async {
    if (state is! RecipeLoaded && state is! RecipeLoading) {
      emit(RecipeLoading());
    }

    try {
      await repository.fetchPaginatedRecipes(page: 1, limit: limit);
    } catch (e) {
      logman.error('Failed to get recipes: $e');
      emit(const RecipeError('Failed to load recipes'));
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await repository.addRecipe(recipe);
    } catch (e) {
      logman.error('Failed to add recipe: $e');
      emit(const RecipeError('Failed to add recipe'));
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await repository.updateRecipe(recipe);
    } catch (e) {
      logman.error('Failed to update recipe: $e');
      emit(const RecipeError('Failed to update recipe'));
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await repository.deleteRecipe(id);
    } catch (e) {
      logman.error('Failed to delete recipe: $e');
      emit(const RecipeError('Failed to delete recipe'));
    }
  }

  Future<void> fetchMoreRecipes({int limit = 10}) async {
    if (state is! RecipeLoaded) return;

    final previousState = state as RecipeLoaded;

    if (previousState.page >= previousState.totalPages) {
      return;
    }

    final nextPage = previousState.page + 1;

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
    } catch (e) {
      logman.error('Failed to paginate recipes: $e');

      emit(
        RecipeLoaded(
          recipes: previousState.recipes,
          page: previousState.page,
          totalPages: previousState.totalPages,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _recipeSubscription?.cancel();
    return super.close();
  }
}
