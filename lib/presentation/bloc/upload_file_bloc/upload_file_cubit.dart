import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pride/presentation/bloc/upload_file_bloc/upload_file_state.dart';
import 'package:pride/presentation/screen/student_form/student_form_screen.dart';

import '../../../domain/exceptions/login_exception.dart';

import '../../../domain/models/edit_template_models/edit_template_request.dart';
import '../../../domain/models/edit_template_models/edit_template_response.dart';
import '../../../domain/models/external_file_upload_models/external_file_upload_request.dart';
import '../../../domain/models/external_file_upload_models/external_file_upload_response.dart';
import '../../../domain/repositories/main_repository.dart';

class UploadFileCubit extends Cubit<UploadFileState> {
  UploadFileCubit() : super(UploadFileLoadingState());

  final MainRepository _mainRepository = MainRepository();

  Future<void> fetchUploadedFiles(
      {required ExternalUploadFileRequest request,
      ImageMapperEnum? key}) async {
    try {
      emit(UploadFileLoadingState());
      ExternalUploadFileResponse uploadFileResponse =
          await _mainRepository.uploadFile(request);

      emit(UploadFileSuccessState(uploadFileResponse, key));
    } catch (error) {
      emit(UploadFileErrorState("An error occurred. Please try again."));
    }
  }
}
