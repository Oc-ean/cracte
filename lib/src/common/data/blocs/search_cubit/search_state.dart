part of 'search_cubit.dart';

abstract class RecipeSearchState extends Equatable {
  const RecipeSearchState();

  @override
  List<Object?> get props => [];
}

class RecipeSearchInitial extends RecipeSearchState {}

class RecipeSearchLoading extends RecipeSearchState {}

class RecipeSearchLoaded extends RecipeSearchState {
  final List<Recipe> recipes;
  final String query;

  const RecipeSearchLoaded({required this.recipes, required this.query});

  @override
  List<Object?> get props => [recipes, query];
}

class RecipeSearchEmpty extends RecipeSearchState {}

class RecipeSearchError extends RecipeSearchState {
  final String message;

  const RecipeSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
