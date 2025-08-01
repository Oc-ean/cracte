import 'package:cracte/src/common/common.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'category_recipe_state.dart';

class CategoryRecipeCubit extends Cubit<CategoryRecipeState> {
  final RecipeRepository _recipeRepository;
  final String _categoryId;

  CategoryRecipeCubit({
    required RecipeRepository recipeRepository,
    required String categoryId,
  })  : _recipeRepository = recipeRepository,
        _categoryId = categoryId,
        super(CategoryRecipeInitial()) {
    getRecipesByCategoryId();
  }

  Future<void> getRecipesByCategoryId() async {
    if (state is! CategoryRecipeLoaded && state is! CategoryRecipeLoading) {
      emit(CategoryRecipeLoading());
    }

    try {
      final recipes = await _recipeRepository.getRecipes();
      final categoryRecipes =
          recipes.where((r) => r.category.id == _categoryId).toList();

      if (categoryRecipes.isEmpty) {
        emit(CategoryRecipeEmpty());
      } else {
        emit(CategoryRecipeLoaded(categoryRecipes));
      }
    } catch (e, stackTrace) {
      logman.error('Failed to get category recipes: $e',
          stackTrace: stackTrace);
      emit(const CategoryRecipeError('Failed to load recipes'));
    }
  }
}
