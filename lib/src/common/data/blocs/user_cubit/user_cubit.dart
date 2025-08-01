import 'dart:async';

import 'package:cracte/src/common/common.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository repository;
  StreamSubscription<User?>? _userSubscription;

  UserCubit({required this.repository}) : super(UserInitial()) {
    listenToCurrentUser();
    getUser();
  }

  Future<void> getUser() async {
    emit(UserLoading());
    try {
      final user = await repository.getCurrentUser();
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserEmpty());
      }
    } catch (e) {
      emit(const UserError('Failed to get user'));
    }
  }

  void listenToCurrentUser() {
    emit(UserLoading());
    _userSubscription?.cancel();
    _userSubscription = repository.getCurrentUserStream().listen(
      (user) {
        if (user != null) {
          emit(UserLoaded(user));
        } else {
          emit(const UserError('User not found'));
        }
      },
      onError: (Object e) => emit(UserError('Error streaming user: $e')),
    );
  }

  Future<void> saveUser(User user) async {
    try {
      await repository.saveCurrentUser(user);
      emit(UserLoaded(user));
    } catch (e) {
      emit(const UserError('Failed to save user'));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
