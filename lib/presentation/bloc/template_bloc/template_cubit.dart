import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pride/presentation/bloc/template_bloc/template_state.dart';

import '../../../domain/exceptions/template_exception.dart';
import '../../../domain/models/template_models/template_response.dart';
import '../../../domain/repositories/main_repository.dart';

class TemplateCubit extends Cubit<TemplateState> {
  TemplateCubit() : super(TemplateLoadingState());

  final MainRepository _mainRepository = MainRepository();

  Future<void> fetchTemplates() async {
    try {
      emit(TemplateLoadingState());
      TemplateResponse templateResponse =
          await _mainRepository.fetchTemplates();

      if (templateResponse.data?.templates?.isNotEmpty == true) {
        emit(TemplateSuccessState(templateResponse));
      } else {
        throw Exception('No Templates Found');
      }
    } on TemplateApplicationException catch (error) {
      if (error is TemplateApplicationException) {
        final fieldErrors = error.fieldErrors ?? {};
        final nonFieldError = error.nonFieldErrors ?? {};
        final generalFieldError = error.generalFieldErrors ?? {};

        if (fieldErrors.isNotEmpty == true) {
          print("fetchTemplatesErrorfield ${fieldErrors}");
          emit(TemplateFieldErrorState(fieldErrors));
        } else if (nonFieldError.isNotEmpty == true) {
          print("fetchTemplatesErrorNonField ${nonFieldError}");
          emit(TemplateNonFieldErrorState(nonFieldError));
        } else if (generalFieldError.isNotEmpty == true) {
          emit(TemplateGeneralFieldErrorState(generalFieldError));
        } else {
          print("fetchTemplatesError ${error.toString()}");
          emit(TemplateErrorState(error.toString()));
        }
      } else {
        print("fetchTemplatesErrorGeneral ${error.toString()}");
        emit(TemplateErrorState(error.toString()));
      }
    }
  }
}
