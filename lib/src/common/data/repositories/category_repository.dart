import 'package:cracte/src/common/common.dart';

class CategoryRepository {
  final CategoryDataSource _dataSource;

  CategoryRepository({required CategoryDataSource dataSource})
      : _dataSource = dataSource;

  Future<List<Recipe>> saveDefaultCategories(List<Category> categories) async {
    if (recipes.isEmpty) {
      return [];
    }
    await _dataSource.saveCategories(categories);

    return recipes;
  }

  Future<List<Category>> getCategories() async {
    try {
      return await _dataSource.getCategories();
    } catch (e, s) {
      logman.error('Failed to fetch categories: $e', stackTrace: s);
      return [];
    }
  }

  Stream<List<Category>> getCategoriesStream() =>
      _dataSource.getCategoriesStream();

  void dispose() {
    _dataSource.dispose();
  }
}
