part of 'recipe_cubit.dart';

abstract class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object?> get props => [];
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final List<Recipe> recipes;
  final bool isPaginating;
  final int page;
  final int totalPages;

  const RecipeLoaded({
    required this.recipes,
    this.isPaginating = false,
    required this.page,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [recipes, isPaginating, page, totalPages];
}

class RecipeEmpty extends RecipeState {}

class RecipeError extends RecipeState {
  final String message;

  const RecipeError(this.message);

  @override
  List<Object?> get props => [message];
}
