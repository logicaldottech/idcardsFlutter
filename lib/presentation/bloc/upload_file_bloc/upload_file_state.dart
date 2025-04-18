import 'package:untitled/domain/models/external_file_upload_models/external_file_upload_response.dart';
import 'package:untitled/presentation/screen/student_form/student_form_screen.dart';

abstract class UploadFileState {}

class UploadFileLoadingState extends UploadFileState {}

class UploadFileRequestLoadingState extends UploadFileState {}

class UploadFileSuccessState extends UploadFileState {
  final ExternalUploadFileResponse response;
  final ImageMapperEnum? key;

  UploadFileSuccessState(this.response, this.key);

  @override
  String toString() =>
      'UploadFileSuccessState(response: $response) key :- $key';
}

// State for general file upload errors
class UploadFileErrorState extends UploadFileState {
  final String error;

  UploadFileErrorState(this.error);

  @override
  String toString() => 'UploadFileErrorState(error: $error)';
}

// State for field-specific errors in file upload
class UploadFileFieldErrorState extends UploadFileState {
  final Map<String, List<String>>? fieldErrors;

  UploadFileFieldErrorState(this.fieldErrors);

  @override
  String toString() => 'UploadFileFieldErrorState(fieldErrors: $fieldErrors)';
}

// State for non-field-specific errors in file upload
class UploadFileNonFieldErrorState extends UploadFileState {
  final Map<String, List<String>>? nonFieldErrors;

  UploadFileNonFieldErrorState(this.nonFieldErrors);

  @override
  String toString() =>
      'UploadFileNonFieldErrorState(nonFieldErrors: $nonFieldErrors)';
}

// State for general field errors in file upload
class UploadFileGeneralFieldErrorState extends UploadFileState {
  final Map<String, List<String>>? generalFieldErrors;

  UploadFileGeneralFieldErrorState(this.generalFieldErrors);

  @override
  String toString() =>
      'UploadFileGeneralFieldErrorState(generalFieldErrors: $generalFieldErrors)';
}
