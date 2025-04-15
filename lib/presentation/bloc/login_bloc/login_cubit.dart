import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/data_sources/local/preference_utils.dart';
import '../../../domain/exceptions/login_exception.dart';
import '../../../domain/models/loginModels/LoginResponse.dart';
import '../../../domain/models/loginModels/login_request.dart';
import '../../../domain/repositories/main_repository.dart';
import '../../../utils/app_constants.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginLoadingState());

  final MainRepository _mainRepository = MainRepository();

  Future<void> login(LoginRequest request) async {
    try {
      emit(LoginRequestLoadingState());
      print("Login request initiated: ${request.toJson()}");

      LoginResponse? loginResponse = await _mainRepository.postLogin(request);
      print("Login API response: $loginResponse");

      if (loginResponse.data.token.isNotEmpty == true) {
        print("token Login token ${loginResponse.data.token}");
        await PreferencesUtil.saveString(AppConstants.authToken, loginResponse.data.token);
        await PreferencesUtil.saveString(AppConstants.schoolId, loginResponse.data.schoolId);
        emit(LoginSuccessState(loginResponse));
      } else {
        print("Login failed: Invalid response or missing token.");
        emit(LoginErrorState("Invalid login response. Please try again."));
      }
    } on LoginApplicationException catch (error) {
      print("LoginApplicationException caught: $error");

      final fieldErrors = error.fieldErrors ?? {};
      final nonFieldError = error.nonFieldErrors ?? {};
      final generalFieldError = error.generalFieldErrors ?? {};

      if (fieldErrors.isNotEmpty) {
        print("Login Field Errors: $fieldErrors");
        emit(LoginFieldErrorState(fieldErrors));
      } else if (nonFieldError.isNotEmpty) {
        print("Login Non-Field Errors: $nonFieldError");
        emit(LoginNonFieldErrorState(nonFieldError));
      } else if (generalFieldError.isNotEmpty) {
        print("Login General Errors: $generalFieldError");
        emit(LoginGeneralFieldErrorState(generalFieldError));
      } else {
        emit(LoginErrorState("Unexpected login error occurred."));
      }
    } catch (error, stackTrace) {
      print("Unhandled login error: $error");
      print(stackTrace);
      emit(LoginErrorState("An error occurred. Please try again."));
    }
  }
}
