import '../../../domain/models/loginModels/LoginResponse.dart';

abstract class LoginState {}

// State when login request is loading
class LoginLoadingState extends LoginState {}

// State when login request is loading
class LoginRequestLoadingState extends LoginState {}

// State for successful login with response data
class LoginSuccessState extends LoginState {
  final LoginResponse response;

  LoginSuccessState(this.response);

  @override
  String toString() => 'LoginSuccessState(response: $response)';
}

// State for general login errors
class LoginErrorState extends LoginState {
  final String? error;

  LoginErrorState(this.error);

  @override
  String toString() => 'LoginErrorState(error: $error)';
}

// State for field-specific login errors
class LoginFieldErrorState extends LoginState {
  final Map<String, List<String>>? fieldErrors;

  LoginFieldErrorState(this.fieldErrors);

  @override
  String toString() => 'LoginFieldErrorState(fieldErrors: $fieldErrors)';
}
class LoginNonFieldErrorState extends LoginState {
  final Map<String, List<String>>? nonFieldErrors;

  LoginNonFieldErrorState(this.nonFieldErrors);

  @override
  String toString() => 'LoginFieldErrorState(fieldErrors: $nonFieldErrors)';
}
class LoginGeneralFieldErrorState extends LoginState {
  final Map<String, List<String>>? generalFieldErrors;

  LoginGeneralFieldErrorState(this.generalFieldErrors);

  @override
  String toString() => 'LoginFieldErrorState(fieldErrors: $generalFieldErrors)';
}
