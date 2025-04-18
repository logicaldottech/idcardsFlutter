import '../../../domain/models/edit_profile_models/edit_profile_response.dart';

abstract class EditProfileState {}

// State when edit profile request is loading
class EditProfileLoadingState extends EditProfileState {}

// State when edit profile request is processing
class EditProfileRequestLoadingState extends EditProfileState {}

// State for successful profile update with response data
class EditProfileSuccessState extends EditProfileState {
  final EditProfileResponse response;

  EditProfileSuccessState(this.response);

  @override
  String toString() => 'EditProfileSuccessState(response: $response)';
}

// State for general profile update errors
class EditProfileErrorState extends EditProfileState {
  final String error;

  EditProfileErrorState(this.error);

  @override
  String toString() => 'EditProfileErrorState(error: $error)';
}

// State for field-specific errors in profile update
class EditProfileFieldErrorState extends EditProfileState {
  final Map<String, List<String>>? fieldErrors;

  EditProfileFieldErrorState(this.fieldErrors);

  @override
  String toString() => 'EditProfileFieldErrorState(fieldErrors: $fieldErrors)';
}

// State for non-field-specific errors in profile update
class EditProfileNonFieldErrorState extends EditProfileState {
  final Map<String, List<String>>? nonFieldErrors;

  EditProfileNonFieldErrorState(this.nonFieldErrors);
  @override
  String toString() =>
      'EditProfileNonFieldErrorState(nonFieldErrors: $nonFieldErrors)';
}

// State for general field errors in profile update
class EditProfileGeneralFieldErrorState extends EditProfileState {
  final Map<String, List<String>>? generalFieldErrors;
  EditProfileGeneralFieldErrorState(this.generalFieldErrors);

  @override
  String toString() =>
      'EditProfileGeneralFieldErrorState(generalFieldErrors: $generalFieldErrors)';
}
