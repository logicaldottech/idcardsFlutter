import '../../../domain/models/template_models/template_response.dart';

abstract class TemplateState {}

class TemplateLoadingState extends TemplateState {}

class TemplateSuccessState extends TemplateState {
  final TemplateResponse response;

  TemplateSuccessState(this.response);
}

class TemplateErrorState extends TemplateState {
  final String error;

  TemplateErrorState(this.error);
}

// State for field-specific errors related to templates
class TemplateFieldErrorState extends TemplateState {
  final Map<String, List<String>>? fieldErrors;

  TemplateFieldErrorState(this.fieldErrors);

  @override
  String toString() => 'TemplateFieldErrorState(fieldErrors: $fieldErrors)';
}

class TemplateNonFieldErrorState extends TemplateState {
  final Map<String, List<String>>? nonFieldErrors;

  TemplateNonFieldErrorState(this.nonFieldErrors);

  @override
  String toString() => 'TemplateNonFieldErrorState(nonFieldErrors: $nonFieldErrors)';
}

class TemplateGeneralFieldErrorState extends TemplateState {
  final Map<String, List<String>>? generalFieldErrors;

  TemplateGeneralFieldErrorState(this.generalFieldErrors);

  @override
  String toString() => 'TemplateGeneralFieldErrorState(generalFieldErrors: $generalFieldErrors)';
}
