

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local/preference_utils.dart';
import '../../../domain/exceptions/login_exception.dart';
import '../../../domain/models/loginModels/change_password_request.dart';
import '../../../domain/models/loginModels/change_password_response.dart';
import '../../../domain/repositories/main_repository.dart';
import '../../../utils/app_constants.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(ChangePasswordLoadingState());

  final MainRepository _mainRepository = MainRepository();

  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      emit(ChangePasswordLoadingState());
      ChangePasswordResponse loginResponse = await _mainRepository.postChangePassword(request);
      String? token = await PreferencesUtil.getString(AppConstants.authToken);
      print("student ${token}");

      print("forgotResponse ${loginResponse.detail}");
      if(loginResponse.detail?.isNotEmpty == true){
        emit(ChangePasswordSuccessState(loginResponse));
      }
      else{
        throw Exception('Invalid Email Address');
      }

    }
    on LoginApplicationException catch (error) {
      if (error is LoginApplicationException) {
        final fieldErrors = error.fieldErrors ?? {};
        final nonFieldError = error.nonFieldErrors ?? {};
        final generalFieldError = error.generalFieldErrors ?? {};
        if (fieldErrors.isNotEmpty == true) {
          print("changePasswordErrorfield ${fieldErrors}");
          emit(ChangePasswordFieldErrorState(fieldErrors));
        }
        else if (nonFieldError.isNotEmpty == true) {
          print("changePasswordErrorfield ${nonFieldError}");
          emit(ChangePasswordNonFieldErrorState(nonFieldError));
        }
        else if(generalFieldError.isNotEmpty == true){
          emit(ChangePasswordGeneralFieldErrorState(generalFieldError));
        }
        else {
          print("changePasswordErrorNonfield ${fieldErrors}");
          emit(ChangePasswordErrorState(error.toString()));
        }
      }
      else {
        print("changePasswordErrorgeneralfield ${error.toString()}");
        emit(ChangePasswordErrorState(error.toString()));
      }
    }
  }
}
