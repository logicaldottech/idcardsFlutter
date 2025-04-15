

import '../../../domain/models/loginModels/change_password_response.dart';

abstract class ChangePasswordState {}

class ChangePasswordLoadingState extends ChangePasswordState {}

class ChangePasswordSuccessState extends ChangePasswordState {
  final ChangePasswordResponse response;

  ChangePasswordSuccessState(this.response);
}

class ChangePasswordErrorState extends ChangePasswordState {
  final String error;
  ChangePasswordErrorState(this.error);
}

// State for field-specific login errors
class ChangePasswordFieldErrorState extends ChangePasswordState {
  final Map<String, List<String>>? fieldErrors;

  ChangePasswordFieldErrorState(this.fieldErrors);

  @override
  String toString() => 'LoginFieldErrorState(fieldErrors: $fieldErrors)';
}
class ChangePasswordNonFieldErrorState extends ChangePasswordState {
  final Map<String, List<String>>? nonFieldErrors;

   ChangePasswordNonFieldErrorState(this.nonFieldErrors);

  @override
  String toString() => 'LoginFieldErrorState(fieldErrors: $nonFieldErrors)';
}
class ChangePasswordGeneralFieldErrorState extends ChangePasswordState {
  final Map<String, List<String>>? generalFieldErrors;

  ChangePasswordGeneralFieldErrorState(this.generalFieldErrors);

  @override
  String toString() => 'LoginFieldErrorState(fieldErrors: $generalFieldErrors)';
}
