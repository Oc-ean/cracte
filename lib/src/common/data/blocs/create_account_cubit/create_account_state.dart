part of 'create_account_cubit.dart';

sealed class CreateAccountState extends Equatable {
  const CreateAccountState();

  @override
  List<Object?> get props => [];
}

class CreateAccountInitial extends CreateAccountState {}

class CreateAccountLoading extends CreateAccountState {}

class CreateAccountSuccess extends CreateAccountState {}

class CreateAccountFailure extends CreateAccountState {
  final String message;

  const CreateAccountFailure(this.message);

  @override
  List<Object?> get props => [message];
}
