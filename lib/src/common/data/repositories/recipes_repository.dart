import 'dart:async';

import 'package:cracte/src/common/common.dart';

class RecipeRepository {
  final RecipeDataSource _dataSource;

  final StreamController<List<Recipe>> _recipesStreamController =
      StreamController<List<Recipe>>.broadcast();

  List<Recipe> _loadedRecipes = [];
  int _currentPage = 0;
  int _totalRecipes = 0;
  bool _isInitialized = false;

  RecipeRepository({
    required RecipeDataSource dataSource,
  }) : _dataSource = dataSource;

  Future<List<Recipe>> saveDefaultRecipes(List<Recipe> recipes) async {
    if (recipes.isEmpty) {
      return [];
    }
    await _dataSource.saveRecipes(recipes);
    _totalRecipes = recipes.length;
    return recipes;
  }

  Future<List<Recipe>> getRecipes() async {
    try {
      final recipes = await _dataSource.getRecipes();
      _totalRecipes = recipes.length;
      return recipes;
    } catch (e, s) {
      logman.error('Failed to fetch recipes: $e', stackTrace: s);
      return [];
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      final currentRecipes = await getRecipes();
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      final newRecipe = recipe.copyWith(id: newId);

      // Add to beginning of list for better UX
      currentRecipes.insert(0, newRecipe);
      await _dataSource.saveRecipes(currentRecipes);
      _totalRecipes = currentRecipes.length;

      // Reset pagination completely and start fresh
      await _resetPaginationAndFetch();

      if (newRecipe.authorId.isNotEmpty) {
        await getIt<UserRecipeRepository>().fetchPaginatedUserRecipes(page: 1);
      }
    } catch (e, s) {
      logman.error('Failed to add recipe: $e', stackTrace: s);
      rethrow;
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _dataSource.updateRecipe(recipe);

      // Update the recipe in loaded recipes if it exists
      final index = _loadedRecipes.indexWhere((r) => r.id == recipe.id);
      if (index != -1) {
        _loadedRecipes[index] = recipe;
        _recipesStreamController.add(List.from(_loadedRecipes));
      } else {
        // If not in loaded recipes, refresh from current page
        await fetchPaginatedRecipes(page: _currentPage > 0 ? _currentPage : 1);
      }
    } catch (e, s) {
      logman.error('Failed to update recipe: $e', stackTrace: s);
      rethrow;
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final recipes = await getRecipes();
      final filteredRecipes = recipes.where((recipe) {
        final titleMatch =
            recipe.title.toLowerCase().contains(query.toLowerCase());
        final descriptionMatch =
            recipe.description.toLowerCase().contains(query.toLowerCase());
        return titleMatch || descriptionMatch;
      }).toList();

      return filteredRecipes;
    } catch (e, s) {
      logman.error('Failed to search recipes: $e', stackTrace: s);
      return [];
    }
  }

  Future<List<Recipe>> fetchPaginatedRecipes({
    required int page,
    int limit = 10,
    bool refresh = false,
  }) async {
    try {
      // If refresh is true, reset everything
      if (refresh) {
        await _resetPaginationState();
      }

      List<Recipe> allRecipes;
      if (!_isInitialized || _totalRecipes == 0 || refresh) {
        allRecipes = await getRecipes();
        _isInitialized = true;
      } else {
        allRecipes = await _dataSource.getRecipes();
      }

      final total = allRecipes.length;
      _totalRecipes = total;

      final start = (page - 1) * limit;
      if (start >= total) return [];

      final end = start + limit;
      final pageRecipes = allRecipes.sublist(start, end > total ? total : end);

      if (page == 1 || refresh) {
        _loadedRecipes = List.from(pageRecipes);
        _currentPage = 1;
      } else if (page > _currentPage) {
        _loadedRecipes.addAll(pageRecipes);
        _currentPage = page;
      }

      _recipesStreamController.add(List.from(_loadedRecipes));

      return pageRecipes;
    } catch (e, s) {
      logman.error('Failed to fetch paginated recipes: $e', stackTrace: s);
      _recipesStreamController.addError(e);
      return [];
    }
  }

  Future<void> _resetPaginationAndFetch() async {
    await _resetPaginationState();
    await fetchPaginatedRecipes(page: 1, refresh: true);
  }

  Future<void> _resetPaginationState() async {
    _loadedRecipes.clear();
    _currentPage = 0;
    _isInitialized = false;
  }

  Stream<List<Recipe>> get recipesStream => _recipesStreamController.stream;

  int get totalRecipes => _totalRecipes;
  int get currentPage => _currentPage;
  bool get hasMorePages => (_currentPage * 10) < _totalRecipes;

  Future<void> deleteRecipe(String id) async {
    try {
      final recipes = await getRecipes();
      final updatedRecipes = recipes.where((r) => r.id != id).toList();
      await _dataSource.saveRecipes(updatedRecipes);
      _totalRecipes = updatedRecipes.length;

      // Remove from loaded recipes if present
      _loadedRecipes.removeWhere((r) => r.id == id);

      // If we have fewer loaded recipes than expected, try to load more
      final expectedRecipes = _currentPage * 10;
      if (_loadedRecipes.length < expectedRecipes &&
          _loadedRecipes.length < _totalRecipes) {
        await _resetPaginationAndFetch();
      } else {
        _recipesStreamController.add(List.from(_loadedRecipes));
      }
    } catch (e, s) {
      logman.error('Failed to delete recipe: $e', stackTrace: s);
      rethrow;
    }
  }

  void dispose() {
    _recipesStreamController.close();
  }
}
