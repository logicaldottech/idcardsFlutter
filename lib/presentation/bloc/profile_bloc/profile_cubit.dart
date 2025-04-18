import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/domain/exceptions/login_exception.dart';
import '../../../data/data_sources/local/preference_utils.dart';

import '../../../domain/models/profile_models/profile_request.dart';
import '../../../domain/models/profile_models/profile_response.dart';
import '../../../domain/repositories/main_repository.dart';
import '../../../utils/app_constants.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileLoadingState());

  final MainRepository _mainRepository = MainRepository();
  ProfileResponse? get currentUser => _currentUser;
  ProfileResponse? _currentUser;
  Future<void> fetchProfile() async {
    try {
      emit(ProfileRequestLoadingState());
      ProfileResponse? profileResponse = await _mainRepository.fetchProfile();
      _currentUser = profileResponse;
      emit(ProfileSuccessState(profileResponse));
    } catch (error, stackTrace) {
      emit(ProfileErrorState("An error occurred. Please try again."));
    }
  }
}
