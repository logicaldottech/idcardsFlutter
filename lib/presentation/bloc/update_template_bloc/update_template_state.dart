import '../../../domain/models/edit_template_models/edit_template_response.dart';

abstract class UpdateTemplateState {}

// State when update template request is loading
class UpdateTemplateLoadingState extends UpdateTemplateState {}

// State when update template request is processing
class UpdateTemplateRequestLoadingState extends UpdateTemplateState {}

// State for successful template update with response data
class UpdateTemplateSuccessState extends UpdateTemplateState {
  final EditTemplateResponse response;

  UpdateTemplateSuccessState(this.response);

  @override
  String toString() => 'UpdateTemplateSuccessState(response: $response)';
}

// State for general template update errors
class UpdateTemplateErrorState extends UpdateTemplateState {
  final String error;

  UpdateTemplateErrorState(this.error);

  @override
  String toString() => 'UpdateTemplateErrorState(error: $error)';
}

// State for field-specific errors in template update
class UpdateTemplateFieldErrorState extends UpdateTemplateState {
  final Map<String, List<String>>? fieldErrors;

  UpdateTemplateFieldErrorState(this.fieldErrors);

  @override
  String toString() =>
      'UpdateTemplateFieldErrorState(fieldErrors: $fieldErrors)';
}

// State for non-field-specific errors in template update
class UpdateTemplateNonFieldErrorState extends UpdateTemplateState {
  final Map<String, List<String>>? nonFieldErrors;

  UpdateTemplateNonFieldErrorState(this.nonFieldErrors);

  @override
  String toString() =>
      'UpdateTemplateNonFieldErrorState(nonFieldErrors: $nonFieldErrors)';
}

// State for general field errors in template update
class UpdateTemplateGeneralFieldErrorState extends UpdateTemplateState {
  final Map<String, List<String>>? generalFieldErrors;

  UpdateTemplateGeneralFieldErrorState(this.generalFieldErrors);

  @override
  String toString() =>
      'UpdateTemplateGeneralFieldErrorState(generalFieldErrors: $generalFieldErrors)';
}
