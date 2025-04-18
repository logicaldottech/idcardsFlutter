import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/domain/exceptions/login_exception.dart';
import '../../../domain/models/edit_profile_models/edit_profile_request.dart';
import '../../../domain/models/edit_profile_models/edit_profile_response.dart';
import '../../../domain/repositories/main_repository.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit() : super(EditProfileLoadingState());

  final MainRepository _mainRepository = MainRepository();

  Future<void> editProfile(EditProfileRequest request) async {
    try {
      emit(EditProfileRequestLoadingState());
      EditProfileResponse? profileResponse =
          await _mainRepository.postEditProfile(request);
      emit(EditProfileSuccessState(profileResponse));
    } on LoginApplicationException catch (error) {
      print("EditProfileApplicationException caught: $error");

      final fieldErrors = error.fieldErrors ?? {};
      final nonFieldError = error.nonFieldErrors ?? {};
      final generalFieldError = error.generalFieldErrors ?? {};

      if (fieldErrors.isNotEmpty) {
        print("Edit Profile Field Errors: $fieldErrors");
        final error = fieldErrors.values.flattenedToList.join(", ");
        emit(EditProfileErrorState(error));
      } else if (nonFieldError.isNotEmpty) {
        print("Edit Profile Non-Field Errors: $nonFieldError");
        final error = nonFieldError.values.flattenedToList.join(", ");
        emit(EditProfileErrorState(error));
      } else if (generalFieldError.isNotEmpty) {
        print("Edit Profile General Errors: $generalFieldError");
        final error = generalFieldError.values.flattenedToList.join(", ");
        emit(EditProfileErrorState(error));
      } else {
        emit(EditProfileErrorState(
            "Unexpected error occurred while updating profile."));
      }
    } catch (error, stackTrace) {
      print("Unhandled edit profile error: $error");
      print(stackTrace);
      emit(EditProfileErrorState("An error occurred. Please try again."));
    }
  }
}
