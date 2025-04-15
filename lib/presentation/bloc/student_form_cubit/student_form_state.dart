

import '../../../domain/models/student_form_models/student_form_response.dart';

abstract class StudentFormState {}

// State when form submission is loading
class StudentFormLoadingState extends StudentFormState {}

// State when form request is loading
class StudentFormRequestLoadingState extends StudentFormState {}

// State for successful form submission with response data
class StudentFormSuccessState extends StudentFormState {
  final StudentFormResponse response;

  StudentFormSuccessState(this.response);

  @override
  String toString() => 'StudentFormSuccessState(response: $response)';
}

// State for general form errors
class StudentFormErrorState extends StudentFormState {
  final String? error;

  StudentFormErrorState(this.error);

  @override
  String toString() => 'StudentFormErrorState(error: $error)';
}

// State for field-specific form errors
class StudentFormFieldErrorState extends StudentFormState {
  final Map<String, List<String>>? fieldErrors;

  StudentFormFieldErrorState(this.fieldErrors);

  @override
  String toString() => 'StudentFormFieldErrorState(fieldErrors: $fieldErrors)';
}

// State for non-field-specific form errors
class StudentFormNonFieldErrorState extends StudentFormState {
  final Map<String, List<String>>? nonFieldErrors;

  StudentFormNonFieldErrorState(this.nonFieldErrors);

  @override
  String toString() => 'StudentFormNonFieldErrorState(nonFieldErrors: $nonFieldErrors)';
}

// State for general field errors
class StudentFormGeneralFieldErrorState extends StudentFormState {
  final Map<String, List<String>>? generalFieldErrors;

  StudentFormGeneralFieldErrorState(this.generalFieldErrors);

  @override
  String toString() => 'StudentFormGeneralFieldErrorState(generalFieldErrors: $generalFieldErrors)';
}
