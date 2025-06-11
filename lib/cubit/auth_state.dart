import '../models/result_model.dart';
import '../models/user_model.dart';

abstract class AuthStates {
  get accommodations => null;
}

class AuthIntialState extends AuthStates {}

class RegisterLoadingState extends AuthStates {}

class RegisterSuccessState extends AuthStates {}

class FailedRegisterState extends AuthStates {
  String message;
  FailedRegisterState({required this.message});
}
//////////////////////////////////////

class LoginLoadingState extends AuthStates {}

class LoginSuccessState extends AuthStates {}

class FailedLoginState extends AuthStates {
  String message;
  FailedLoginState({required this.message});
}
//////////////////////////////////////

class ForgetpassLoadingState extends AuthStates {}

class ForgetpassSuccessState extends AuthStates {}

class FailedForgetpassState extends AuthStates {
  String message;
  FailedForgetpassState({required this.message});
}
//////////////////////////////////////

class UserInitial extends AuthStates {}

class UserLoading extends AuthStates {}

class UserLoaded extends AuthStates {
  final UserModel user;
  UserLoaded(this.user);
}

class UserError extends AuthStates {
  final String message;
  UserError(this.message);
  List<Object?> get props => [message];
}

class UserUpdated extends AuthStates {
  final UserModel user;
  UserUpdated(this.user);
}

//////////////////////////////////////

class AuthInitialState extends AuthStates {}

class AuthLoadingState extends AuthStates {}

class AuthSuccessState extends AuthStates {}

class AuthErrorState extends AuthStates {
  final String error;
  AuthErrorState(this.error);
}

class ResendOtpSuccessState extends AuthStates {
  final String message;
  ResendOtpSuccessState(this.message);
}
//////////////////////////////////////


class ResultLoading extends AuthStates {}

class ResultLoaded extends AuthStates {
  final List<ResultModel> results;

  ResultLoaded(this.results);
}


class ResultError extends AuthStates {
  final String message;
  ResultError(this.message);
  List<Object?> get props => [message];
}

class ResultCreated extends AuthStates {
  final ResultModel result;
  ResultCreated(this.result);
}