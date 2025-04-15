import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/domain/models/log_out_models/log_out_request.dart';
import 'package:untitled/domain/models/loginModels/login_request.dart';

import '../../../domain/models/log_out_models/log_out_response.dart';
import '../../../domain/repositories/main_repository.dart';
import 'logout_state.dart';


class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit() : super(LogoutLoadingState());
  LogoutResponse? logoutResponse;
  final MainRepository _mainRepository = MainRepository();

  Future<void> logouts({required LogoutRequest logoutRequest}) async {
    try {
      emit(LogoutRequestLoadingState());

      logoutResponse = await _mainRepository.logout(logoutRequest);

      emit(LogoutSuccessState(logoutResponse!));
    } catch (error) {
      emit(LogoutErrorState(logoutResponse?.message ?? "Unknown Network issue"));
    }
  }
}
