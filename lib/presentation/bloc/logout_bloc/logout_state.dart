

import '../../../domain/models/log_out_models/log_out_response.dart';

abstract class LogoutState {}

class LogoutLoadingState extends LogoutState {}

class LogoutRequestLoadingState extends LogoutState {}

class LogoutSuccessState extends LogoutState {
  final LogoutResponse response;

  LogoutSuccessState(this.response);
}

class LogoutErrorState extends LogoutState {
  final String errorResponse;

  LogoutErrorState(this.errorResponse);
}
