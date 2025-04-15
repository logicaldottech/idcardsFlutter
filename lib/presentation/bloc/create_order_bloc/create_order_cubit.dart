import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/domain/exceptions/login_exception.dart';
import '../../../data/data_sources/local/preference_utils.dart';

import '../../../domain/models/create_order_models/create_order_request.dart';
import '../../../domain/models/create_order_models/create_order_response.dart';
import '../../../domain/repositories/main_repository.dart';
import '../../../utils/app_constants.dart';
import 'create_order_state.dart';

class CreateOrderCubit extends Cubit<CreateOrderState> {
  CreateOrderCubit() : super(CreateOrderLoadingState());

  final MainRepository _mainRepository = MainRepository();

  Future<void> createOrder(CreateOrderRequest request) async {
    try {
      emit(CreateOrderRequestLoadingState());
      CreateOrderResponse? orderResponse = await _mainRepository.postCreateOrder(request);
      emit(CreateOrderSuccessState(orderResponse));

    } on  LoginApplicationException catch (error) {
      print("OrderApplicationException caught: $error");

      final fieldErrors = error.fieldErrors ?? {};
      final nonFieldError = error.nonFieldErrors ?? {};
      final generalFieldError = error.generalFieldErrors ?? {};

      if (fieldErrors.isNotEmpty) {
        print("Create Order Field Errors: $fieldErrors");
        emit(CreateOrderFieldErrorState(fieldErrors));
      } else if (nonFieldError.isNotEmpty) {
        print("Create Order Non-Field Errors: $nonFieldError");
        emit(CreateOrderNonFieldErrorState(nonFieldError));
      } else if (generalFieldError.isNotEmpty) {
        print("Create Order General Errors: $generalFieldError");
        emit(CreateOrderGeneralFieldErrorState(generalFieldError));
      } else {
        emit(CreateOrderErrorState("Unexpected error occurred while creating order."));
      }
    } catch (error, stackTrace) {
      print("Unhandled create order error: $error");
      print(stackTrace);
      emit(CreateOrderErrorState("An error occurred. Please try again."));
    }
  }
}
