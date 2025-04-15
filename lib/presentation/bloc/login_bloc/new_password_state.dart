

import '../../../domain/models/loginModels/new_pasword_response.dart';

abstract class NewPasswordState {}

class NewPasswordLoadingState extends NewPasswordState {}

class NewPasswordSuccessState extends NewPasswordState {
  final NewPasswordResponse response;

  NewPasswordSuccessState(this.response);
}

class NewPasswordErrorState extends NewPasswordState {
  final String error;
  NewPasswordErrorState(this.error);
}

// State for field-specific login errors
class NewPasswordFieldErrorState extends NewPasswordState {
  final Map<String, List<String>>? fieldErrors;

  NewPasswordFieldErrorState(this.fieldErrors);

  @override
  String toString() => 'LoginFieldErrorState(fieldErrors: $fieldErrors)';
}
class NewPasswordNonFieldErrorState extends NewPasswordState {
  final Map<String, List<String>>? nonFieldErrors;

  NewPasswordNonFieldErrorState(this.nonFieldErrors);

  @override
  String toString() => 'LoginFieldErrorState(fieldErrors: $nonFieldErrors)';
}
class NewPasswordGeneralFieldErrorState extends NewPasswordState {
  final Map<String, List<String>>? generalFieldErrors;
  NewPasswordGeneralFieldErrorState(this.generalFieldErrors);
  @override
  String toString() => 'LoginFieldErrorState(fieldErrors: $generalFieldErrors)';
}
