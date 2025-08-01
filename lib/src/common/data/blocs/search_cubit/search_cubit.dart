import 'package:cracte/src/common/common.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_state.dart';

class RecipeSearchCubit extends Cubit<RecipeSearchState> {
  final RecipeRepository _recipeRepository;

  RecipeSearchCubit({required RecipeRepository recipeRepository})
      : _recipeRepository = recipeRepository,
        super(RecipeSearchInitial());

  Future<void> searchGoals({required String query}) async {
    emit(RecipeSearchInitial());

    if (query.trim().isEmpty) {
      emit(RecipeSearchEmpty());
      return;
    }

    emit(RecipeSearchLoading());
    final recipes = await _recipeRepository.searchRecipes(query);
    if (recipes.isEmpty) {
      emit(RecipeSearchEmpty());
    } else {
      emit(RecipeSearchLoaded(recipes: recipes, query: query));
    }
  }

  void clearSearch() {
    emit(RecipeSearchInitial());
  }
}
