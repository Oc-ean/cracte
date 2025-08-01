part of 'favourite_recipe_cubit.dart';

abstract class FavouriteRecipeState extends Equatable {
  const FavouriteRecipeState();

  @override
  List<Object> get props => [];
}

class FavouriteRecipeInitial extends FavouriteRecipeState {}

class FavouriteRecipeLoading extends FavouriteRecipeState {}

class FavouriteRecipeLoaded extends FavouriteRecipeState {
  final List<Recipe> recipes;
  const FavouriteRecipeLoaded(this.recipes);
}

class FavouriteRecipeError extends FavouriteRecipeState {
  final String message;
  const FavouriteRecipeError(this.message);

  @override
  List<Object> get props => [message];
}
