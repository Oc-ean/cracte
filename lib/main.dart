import 'package:cracte/src/app.dart';
import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(FavouriteRecipeAdapter());
  await Hive.openBox<Recipe>('recipes');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<User>('users');
  await Hive.openBox<User>('current_user');
  await Hive.openBox<FavouriteRecipe>('favorite_recipes');
  await Hive.openBox<String>('app_theme');
  setupLocator();

  Bloc.observer = AppBlocObserver();

  runApp(const App());
}
