import 'dart:async';

import 'package:cracte/src/common/common.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository repository;
  final RecipeRepository recipeRepository;

  StreamSubscription<List<Category>>? _categorySubscription;

  CategoryCubit({required this.repository, required this.recipeRepository})
      : super(CategoryInitial()) {
    saveDefaultCategories();
    _subscribeToCategories();
  }

  void _subscribeToCategories() {
    _categorySubscription?.cancel();

    _categorySubscription = repository.getCategoriesStream().listen(
      (categories) {
        if (categories.isEmpty) {
          emit(CategoryEmpty());
        } else {
          emit(CategoryLoaded(categories));
        }
      },
      onError: (Object error) {
        logman.error('Category stream error: $error');
        emit(const CategoryError('Failed to load categories'));
      },
    );
  }

  Future<void> getCategories() async {
    if (state is! CategoryLoaded && state is! CategoryLoading) {
      emit(CategoryLoading());
    }

    try {
      final categories = await repository.getCategories();
      if (categories.isEmpty) {
        emit(CategoryEmpty());
      } else {
        emit(CategoryLoaded(categories));
      }
    } catch (e) {
      logman.error('Failed to get categories: $e');
      emit(const CategoryError('Failed to load categories'));
    }
  }

  Future<void> saveDefaultCategories() async {
    try {
      final existing = await repository.getCategories();
      if (existing.isEmpty) {
        await repository.saveDefaultCategories(categories);
      }
      await getCategories();
    } catch (e) {
      logman.error('Failed to save default categories: $e');
    }
  }

  Future<List<Recipe>> getRecipesByCategoryId(String categoryId) async {
    try {
      final recipes = await recipeRepository.getRecipes();
      return recipes.where((r) => r.category.id == categoryId).toList();
    } catch (e) {
      logman.error('Failed to get category recipes: $e');
      return [];
    }
  }

  @override
  Future<void> close() {
    _categorySubscription?.cancel();
    return super.close();
  }
}
