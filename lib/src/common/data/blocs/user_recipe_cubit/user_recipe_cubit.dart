import 'dart:async';

import 'package:cracte/src/common/common.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_recipe_state.dart';

class UserRecipeCubit extends Cubit<UserRecipeState> {
  final UserRecipeRepository _userRecipeRepository;

  StreamSubscription<List<Recipe>>? _userRecipeSubscription;

  UserRecipeCubit({
    required UserRecipeRepository userRecipeRepository,
  })  : _userRecipeRepository = userRecipeRepository,
        super(UserRecipeInitial()) {
    _subscribeToUserRecipes();
  }
  void _subscribeToUserRecipes() {
    _userRecipeSubscription?.cancel();

    _userRecipeSubscription = _userRecipeRepository.userRecipesStream.listen(
      (cumulativeUserRecipes) async {
        try {
          final totalUserRecipes = await _userRecipeRepository.getUserRecipes();
          if (totalUserRecipes.isEmpty) {
            emit(UserRecipeEmpty());
            return;
          }

          const limit = 10;
          final totalPages = (totalUserRecipes.length / limit).ceil();

          final currentPage = (cumulativeUserRecipes.length / limit).ceil();
          final hasMorePages =
              cumulativeUserRecipes.length < totalUserRecipes.length;

          emit(UserRecipeLoaded(
            recipes: cumulativeUserRecipes,
            page: currentPage,
            totalPages: totalPages,
            hasMorePages: hasMorePages,
          ));
        } catch (e) {
          logman.error('Error processing user recipe stream: $e');
        }
      },
      onError: (Object error) {
        logman.error('User recipe stream error: $error');
        emit(const UserRecipeError('Failed to load user recipes'));
      },
    );
  }

  Future<void> getUserRecipes({int limit = 10}) async {
    emit(UserRecipeLoading());
    try {
      final totalUserRecipes = await _userRecipeRepository.getUserRecipes();
      if (totalUserRecipes.isEmpty) {
        emit(UserRecipeEmpty());
        return;
      }

      await _userRecipeRepository.fetchPaginatedUserRecipes(
        page: 1,
        limit: limit,
      );
    } catch (e) {
      emit(const UserRecipeError('Failed to load user recipes'));
    }
  }
}
