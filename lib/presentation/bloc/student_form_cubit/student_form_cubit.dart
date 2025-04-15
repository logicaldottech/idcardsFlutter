import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/data_sources/local/preference_utils.dart';

import '../../../domain/exceptions/login_exception.dart';
import '../../../domain/models/student_form_models/student_form_request.dart';
import '../../../domain/models/student_form_models/student_form_response.dart';
import '../../../domain/repositories/main_repository.dart';
import '../../../utils/app_constants.dart';
import 'student_form_state.dart';

class StudentFormCubit extends Cubit<StudentFormState> {
  StudentFormCubit() : super(StudentFormLoadingState());

  final MainRepository _mainRepository = MainRepository();

  Future<void> submitStudentForm(StudentFormRequest request) async {
    try {
      emit(StudentFormRequestLoadingState());
      print("Student form submission initiated: \${request.toJson()}");

      StudentFormResponse? response = await _mainRepository.postStudentForm(request);
      print("Student form API response: \$response");

      if (response.data.id.isNotEmpty == true) {

        emit(StudentFormSuccessState(response));
      } else {
        print("Student form submission failed: Invalid response or missing ID.");
        emit(StudentFormErrorState("Invalid response. Please try again."));
      }
    } on LoginApplicationException catch (error) {
      print("StudentFormApplicationException caught: \$error");

      final fieldErrors = error.fieldErrors ?? {};
      final nonFieldErrors = error.nonFieldErrors ?? {};
      final generalFieldErrors = error.generalFieldErrors ?? {};

      if (fieldErrors.isNotEmpty) {
        print("Student Form Field Errors: \$fieldErrors");
        emit(StudentFormFieldErrorState(fieldErrors));
      } else if (nonFieldErrors.isNotEmpty) {
        print("Student Form Non-Field Errors: \$nonFieldErrors");
        emit(StudentFormNonFieldErrorState(nonFieldErrors));
      } else if (generalFieldErrors.isNotEmpty) {
        print("Student Form General Errors: \$generalFieldErrors");
        emit(StudentFormGeneralFieldErrorState(generalFieldErrors));
      } else {
        emit(StudentFormErrorState("Unexpected error occurred."));
      }
    } catch (error, stackTrace) {
      print("Unhandled student form error: \$error");
      print(stackTrace);
      emit(StudentFormErrorState("An error occurred. Please try again."));
    }
  }
}
