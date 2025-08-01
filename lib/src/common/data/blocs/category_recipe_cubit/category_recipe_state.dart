part of 'category_recipe_cubit.dart';

abstract class CategoryRecipeState extends Equatable {
  const CategoryRecipeState();

  @override
  List<Object> get props => [];
}

class CategoryRecipeInitial extends CategoryRecipeState {}

class CategoryRecipeLoading extends CategoryRecipeState {}

class CategoryRecipeLoaded extends CategoryRecipeState {
  final List<Recipe> recipes;
  const CategoryRecipeLoaded(this.recipes);
}

class CategoryRecipeEmpty extends CategoryRecipeState {}

class CategoryRecipeError extends CategoryRecipeState {
  final String message;
  const CategoryRecipeError(this.message);

  @override
  List<Object> get props => [message];
}
