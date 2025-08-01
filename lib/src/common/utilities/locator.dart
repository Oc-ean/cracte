import 'package:cracte/src/common/common.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt
    ..registerLazySingleton(
      () => CurrentAppThemeService(),
    )
    ..registerLazySingleton(
      () => CurrentAppThemeCubit(
        currentAppThemeService: getIt<CurrentAppThemeService>(),
      ),
    )
    ..registerLazySingleton<UserDataSource>(
      () => UserDataSource(),
    )
    ..registerLazySingleton<CategoryDataSource>(
      () => CategoryDataSource(),
    )
    ..registerLazySingleton<RecipeDataSource>(
      () => RecipeDataSource(),
    )
    ..registerLazySingleton<FavoriteRecipeDataSource>(
      () => FavoriteRecipeDataSource(),
    )
    ..registerLazySingleton<UserRepository>(
      () => UserRepository(
        dataSource: getIt<UserDataSource>(),
      ),
    )
    ..registerLazySingleton<RecipeRepository>(
      () => RecipeRepository(
        dataSource: getIt<RecipeDataSource>(),
      ),
    )
    ..registerLazySingleton<CategoryRepository>(
      () => CategoryRepository(dataSource: getIt<CategoryDataSource>()),
    )
    ..registerLazySingleton<UserRecipeRepository>(
      () => UserRecipeRepository(
        userRepository: getIt<UserRepository>(),
        recipeRepository: getIt<RecipeRepository>(),
      ),
    )
    ..registerLazySingleton<UserCubit>(
      () => UserCubit(repository: getIt<UserRepository>()),
    )
    ..registerLazySingleton<CategoryCubit>(
      () => CategoryCubit(
        repository: getIt<CategoryRepository>(),
        recipeRepository: getIt<RecipeRepository>(),
      ),
    )
    ..registerLazySingleton<RecipeCubit>(
      () => RecipeCubit(
        repository: getIt<RecipeRepository>(),
        categoryRepository: getIt<CategoryRepository>(),
      ),
    )
    ..registerLazySingleton<FavouriteRecipeCubit>(
      () => FavouriteRecipeCubit(
        favouriteDataSource: getIt<FavoriteRecipeDataSource>(),
        recipeDataSource: getIt<RecipeDataSource>(),
      ),
    )
    ..registerLazySingleton<FollowCubit>(
      () => FollowCubit(
        userRepository: getIt<UserRepository>(),
      ),
    )
    ..registerLazySingleton<RecipeSearchCubit>(
      () => RecipeSearchCubit(
        recipeRepository: getIt<RecipeRepository>(),
      ),
    );
}
