import 'dart:async';

import 'package:cracte/src/common/common.dart';

class UserRecipeRepository {
  final UserRepository _userRepository;
  final RecipeRepository _recipeRepository;

  final StreamController<List<Recipe>> _userRecipesStreamController =
      StreamController<List<Recipe>>.broadcast();

  List<Recipe> _loadedUserRecipes = [];
  int _currentUserPage = 0;

  UserRecipeRepository({
    required UserRepository userRepository,
    required RecipeRepository recipeRepository,
  })  : _userRepository = userRepository,
        _recipeRepository = recipeRepository;

  Future<List<Recipe>> getUserRecipes() async {
    try {
      final user = await _userRepository.getCurrentUser();

      final allRecipes = await _recipeRepository.getRecipes();
      return allRecipes.where((recipe) => recipe.authorId == user!.id).toList();
    } catch (e, s) {
      logman.error('Failed to fetch user recipes: $e', stackTrace: s);
      return [];
    }
  }

  Future<List<Recipe>> fetchPaginatedUserRecipes({
    required int page,
    int limit = 10,
  }) async {
    try {
      final allUserRecipes = await getUserRecipes();
      final total = allUserRecipes.length;

      final start = (page - 1) * limit;
      if (start >= total) return [];

      final end = start + limit;
      final pageRecipes =
          allUserRecipes.sublist(start, end > total ? total : end);

      if (page == 1) {
        _loadedUserRecipes = pageRecipes;
        _currentUserPage = 1;
      } else if (page > _currentUserPage) {
        _loadedUserRecipes.addAll(pageRecipes);
        _currentUserPage = page;
      }

      _userRecipesStreamController.add(List.from(_loadedUserRecipes));

      return pageRecipes;
    } catch (e, s) {
      logman.error('Failed to fetch paginated user recipes: $e', stackTrace: s);
      _userRecipesStreamController.addError(e);
      return [];
    }
  }

  Stream<List<Recipe>> get userRecipesStream =>
      _userRecipesStreamController.stream;

  void dispose() {
    _userRecipesStreamController.close();
  }
}
