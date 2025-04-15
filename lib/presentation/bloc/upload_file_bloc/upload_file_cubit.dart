import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:untitled/presentation/bloc/upload_file_bloc/upload_file_state.dart';

import '../../../domain/exceptions/login_exception.dart';

import '../../../domain/models/edit_template_models/edit_template_request.dart';
import '../../../domain/models/edit_template_models/edit_template_response.dart';
import '../../../domain/models/external_file_upload_models/external_file_upload_request.dart';
import '../../../domain/models/external_file_upload_models/external_file_upload_response.dart';
import '../../../domain/repositories/main_repository.dart';

class UploadFileCubit extends Cubit<UploadFileState> {
  UploadFileCubit() : super(UploadFileLoadingState());

  final MainRepository _mainRepository = MainRepository();

  Future<void> fetchUploadedFiles({required ExternalUploadFileRequest request}) async {
    try {
      emit(UploadFileLoadingState());
      ExternalUploadFileResponse uploadFileResponse = await _mainRepository.uploadFile(request);

      await Future.delayed(Duration(seconds: 2));
      emit(UploadFileSuccessState(uploadFileResponse));
    } catch (error) {

    }
  }
}
