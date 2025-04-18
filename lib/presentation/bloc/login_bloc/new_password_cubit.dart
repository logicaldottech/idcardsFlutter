import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/exceptions/login_exception.dart';
import '../../../domain/models/loginModels/new_password_request.dart';
import '../../../domain/models/loginModels/new_pasword_response.dart';
import '../../../domain/repositories/main_repository.dart';
import 'new_password_state.dart';

class NewPasswordCubit extends Cubit<NewPasswordState> {
  NewPasswordCubit() : super(NewPasswordLoadingState());

  final MainRepository _mainRepository = MainRepository();

  Future<void> newPassword(NewPasswordRequest request) async {
    try {
      emit(NewPasswordLoadingState());
      NewPasswordResponse loginResponse =
          await _mainRepository.postNewPassword(request);
      print("forgotResponse ${loginResponse.message}");
      if (loginResponse.message?.isNotEmpty == true) {
        emit(NewPasswordSuccessState(loginResponse));
      } else {
        throw Exception('Invalid Email Address');
      }
    } on LoginApplicationException catch (error) {
      if (error is LoginApplicationException) {
        final fieldErrors = error.fieldErrors ?? {};
        final nonFieldError = error.nonFieldErrors ?? {};
        final generalFieldError = error.generalFieldErrors ?? {};
        if (fieldErrors.isNotEmpty == true) {
          print("changePasswordErrorfield ${fieldErrors}");
          final error = fieldErrors.values.flattenedToList.join(", ");
          emit(NewPasswordErrorState(error));
        } else if (nonFieldError.isNotEmpty == true) {
          print("changePasswordErrorfield ${nonFieldError}");
          final error = nonFieldError.values.flattenedToList.join(", ");
          emit(NewPasswordErrorState(error));
        } else if (generalFieldError.isNotEmpty == true) {
          final error = generalFieldError.values.flattenedToList.join(", ");
          emit(NewPasswordErrorState(error));
        } else {
          print("changePasswordErrorNonfield ${fieldErrors}");
          emit(NewPasswordErrorState(error.toString()));
        }
      } else {
        print("changePasswordErrorgeneralfield ${error.toString()}");
        emit(NewPasswordErrorState(error.toString()));
      }
    }
  }
}
