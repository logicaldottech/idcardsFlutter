import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pride/data/data_sources/local/database_helper.dart';
import 'package:pride/domain/exceptions/login_exception.dart';
import 'package:pride/domain/models/external_file_upload_models/external_file_upload_request.dart';
import 'package:pride/domain/models/external_file_upload_models/external_file_upload_response.dart';
import 'package:pride/domain/models/student_form_models/order_pre_data.dart';
import '../../../data/data_sources/local/preference_utils.dart';

import '../../../domain/models/create_order_models/create_order_request.dart';
import '../../../domain/models/create_order_models/create_order_response.dart';
import '../../../domain/repositories/main_repository.dart';
import '../../../utils/app_constants.dart';
import 'create_order_state.dart';

class CreateOrderCubit extends Cubit<CreateOrderState> {
  CreateOrderCubit() : super(CreateOrderLoadingState());

  final MainRepository _mainRepository = MainRepository();

  Future<void> updatePersonImage(ExternalUploadFileRequest request,
      {required OrderPreData orderPreData}) async {
    try {
      emit(UpdateImageLoadingState());
      ExternalUploadFileResponse uploadFileResponse =
          await _mainRepository.uploadFile(request);
      final data = orderPreData.data;
      data['https://api.todaystrends.site/externalFiles/userpic.png'] =
          "https://api.todaystrends.site/externalFiles/${uploadFileResponse.fileName}";
      await DatabaseHelper.instance
          .updateOrder(orderPreData.id, jsonEncode(data));

      emit(UpdateImageSuccessState());
    } catch (error) {
      emit(UpdateImageErrorState("An error occurred. Please try again."));
    }
  }

  Future<void> createOrder(CreateOrderRequest request) async {
    try {
      emit(CreateOrderRequestLoadingState());
      CreateOrderResponse? orderResponse =
          await _mainRepository.postCreateOrder(request);
      emit(CreateOrderSuccessState(orderResponse));
    } on LoginApplicationException catch (error) {
      print("OrderApplicationException caught: $error");

      final fieldErrors = error.fieldErrors ?? {};
      final nonFieldError = error.nonFieldErrors ?? {};
      final generalFieldError = error.generalFieldErrors ?? {};

      if (fieldErrors.isNotEmpty) {
        print("Create Order Field Errors: $fieldErrors");
        final error = fieldErrors.values.flattenedToList.join(", ");
        emit(CreateOrderErrorState(error));
      } else if (nonFieldError.isNotEmpty) {
        print("Create Order Non-Field Errors: $nonFieldError");
        final error = nonFieldError.values.flattenedToList.join(", ");
        emit(CreateOrderErrorState(error));
      } else if (generalFieldError.isNotEmpty) {
        print("Create Order General Errors: $generalFieldError");
        final error = generalFieldError.values.flattenedToList.join(", ");
        emit(CreateOrderErrorState(error));
      } else {
        emit(CreateOrderErrorState(
            "Unexpected error occurred while creating order."));
      }
    } catch (error, stackTrace) {
      print("Unhandled create order error: $error");
      print(stackTrace);
      emit(CreateOrderErrorState("An error occurred. Please try again."));
    }
  }

  void deleteStudentDetails(int id, {required String tableName}) async {
    try {
      emit(DeleteStudentRecordLoadingState());
      await DatabaseHelper.instance.deleteOrder(id, tableName: tableName);
      await Future.delayed(const Duration(seconds: 1));
      emit(DeleteStudentRecordSuccessState());
    } catch (e) {
      emit(DeleteStudentRecordErrorState(
          'An error occurred. Please try again.'));
    }
  }
}
