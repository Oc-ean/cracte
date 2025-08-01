part of 'user_recipe_cubit.dart';

abstract class UserRecipeState extends Equatable {
  const UserRecipeState();

  @override
  List<Object> get props => [];
}

class UserRecipeInitial extends UserRecipeState {}

class UserRecipeLoading extends UserRecipeState {}

class UserRecipeEmpty extends UserRecipeState {}

class UserRecipeLoaded extends UserRecipeState {
  final List<Recipe> recipes;
  final int page;
  final int totalPages;
  final bool hasMorePages;
  final bool isPaginating;
  const UserRecipeLoaded({
    required this.recipes,
    required this.page,
    required this.totalPages,
    this.hasMorePages = false,
    this.isPaginating = false,
  });
}

class UserRecipeError extends UserRecipeState {
  final String message;
  const UserRecipeError(this.message);

  @override
  List<Object> get props => [message];
}
