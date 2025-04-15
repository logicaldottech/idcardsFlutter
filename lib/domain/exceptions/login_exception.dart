import 'package:dio/dio.dart';
import 'dart:async';

class LoginExceptionHandler {
  static LoginApplicationException handleException(dynamic exception) {
    String errorMessage = "An unknown error occurred";
    Map<String, List<String>> fieldErrors = {};
    Map<String, List<String>> nonFieldErrors = {};
    Map<String, List<String>> generalFieldErrors = {};

    if (exception is DioError) {
      if (exception.response != null && exception.response!.data != null) {
        var errorData = exception.response!.data;
        if (errorData is Map<String, dynamic>) {
          errorData.forEach((key, value) {
            if (key == 'email' || key == 'password' || key == 'otp') {
              fieldErrors[key] = _parseErrorList(value);
            } else if (key == "non_field_errors") {
              nonFieldErrors[key] = _parseErrorList(value);
            } else if (key == "message" || key == "detail") {
              // Assign error message and add to general field errors for UI visibility
              errorMessage = _parseErrorList(value).join(", ");
              generalFieldErrors[key] = _parseErrorList(value);
            } else {
              generalFieldErrors[key] = _parseErrorList(value);
            }
          });
        } else if (errorData is String) {
          errorMessage = errorData;
          generalFieldErrors["error"] = [errorData]; // Ensure it's shown
        }
      } else {
        errorMessage = "Network error: ${exception.message}";
      }
    } else if (exception is FormatException) {
      errorMessage = "Data format error: ${exception.message}";
    } else if (exception is TimeoutException) {
      errorMessage = "Request timeout. Please try again later.";
    } else {
      errorMessage = "An error occurred: ${exception.toString()}";
    }

    return LoginApplicationException(
      errorMessage,
      fieldErrors: fieldErrors,
      nonFieldErrors: nonFieldErrors,
      generalFieldErrors: generalFieldErrors,
    );
  }

  static List<String> _parseErrorList(dynamic value) {
    if (value is List) {
      return List<String>.from(value.map((e) => e.toString()));
    } else {
      return [value.toString()];
    }
  }
}

class LoginApplicationException implements Exception {
  final String message;
  final Map<String, List<String>> fieldErrors;
  final Map<String, List<String>> nonFieldErrors;
  final Map<String, List<String>> generalFieldErrors;

  LoginApplicationException(
      this.message, {
        Map<String, List<String>>? fieldErrors,
        Map<String, List<String>>? nonFieldErrors,
        Map<String, List<String>>? generalFieldErrors,
      })  : fieldErrors = fieldErrors ?? {},
        nonFieldErrors = nonFieldErrors ?? {},
        generalFieldErrors = generalFieldErrors ?? {};

  @override
  String toString() => message;

  Map<String, List<String>> getFieldErrors() => fieldErrors;
  Map<String, List<String>> getNonFieldErrors() => nonFieldErrors;
  Map<String, List<String>> getGeneralFieldErrors() => generalFieldErrors;
}
