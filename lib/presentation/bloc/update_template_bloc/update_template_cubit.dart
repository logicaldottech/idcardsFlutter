import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:untitled/presentation/bloc/update_template_bloc/update_template_state.dart';


import '../../../domain/exceptions/login_exception.dart';

import '../../../domain/models/edit_template_models/edit_template_request.dart';
import '../../../domain/models/edit_template_models/edit_template_response.dart';
import '../../../domain/repositories/main_repository.dart';

class UpdateTemplateCubit extends Cubit<UpdateTemplateState> {
  UpdateTemplateCubit() : super(UpdateTemplateLoadingState());

  final MainRepository _mainRepository = MainRepository();

  Future<void> fetchUpdatedTemplates({required EditTemplateRequest  request, String? schoolId}) async {
    try {
      emit(UpdateTemplateLoadingState());
      EditTemplateResponse updateTemplateResponse = await _mainRepository.postEditTemplate(request, schoolId!);

      await Future.delayed(Duration(seconds: 1));
        emit(UpdateTemplateSuccessState(updateTemplateResponse));
      }
     catch (error) {

    }
  }
}
