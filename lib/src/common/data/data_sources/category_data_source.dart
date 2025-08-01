import 'dart:async';

import 'package:cracte/src/common/common.dart';

import 'package:hive/hive.dart';

class CategoryDataSource {
  final Box<Category> _categoryBox;
  final StreamController<List<Category>> categoryController =
      StreamController<List<Category>>.broadcast();

  CategoryDataSource() : _categoryBox = Hive.box<Category>('categories');

  Future<List<Category>> getCategories() async {
    try {
      final categories = _categoryBox.values.toList();
      return categories;
    } catch (e) {
      logman.error('Failed to get categories: $e');
      return [];
    }
  }

  Future<void> saveCategories(List<Category> categories) async {
    try {
      await _categoryBox.clear();
      await _categoryBox.addAll(categories);
      categoryController.add(categories);
    } catch (e) {
      logman.error('Failed to save categories: $e');
    }
  }

  Future<void> updateCategory(Category updatedCategory) async {
    try {
      final categories = _categoryBox.values.toList();
      final index = categories.indexWhere((c) => c.id == updatedCategory.id);

      if (index != -1) {
        await _categoryBox.putAt(index, updatedCategory);

        categories[index] = updatedCategory;
        categoryController.add(categories);
      }
    } catch (e) {
      logman.error('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final categories = _categoryBox.values.toList();
      final index = categories.indexWhere((c) => c.id == id);

      if (index != -1) {
        await _categoryBox.deleteAt(index);
        // Remove from local list and emit
        categories.removeAt(index);
        categoryController.add(categories);
      }
    } catch (e) {
      logman.error('Failed to delete category: $e');
    }
  }

  Stream<List<Category>> getCategoriesStream() => categoryController.stream;

  void dispose() {
    categoryController.close();
  }
}
