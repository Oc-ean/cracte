import 'package:cracte/src/common/common.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'create_account_state.dart';

class CreateAccountCubit extends Cubit<CreateAccountState> {
  final UserRepository _userRepository;

  CreateAccountCubit({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(CreateAccountInitial());

  Future<void> createAccount({required User user}) async {
    emit(CreateAccountLoading());

    try {
      Future<void>.delayed(const Duration(seconds: 2));
      await _userRepository.saveCurrentUser(user);

      emit(
        CreateAccountSuccess(),
      );
    } catch (e) {
      emit(CreateAccountFailure(e.toString()));
    }
  }
}
