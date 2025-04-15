import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/domain/exceptions/login_exception.dart';

import '../../../domain/models/order_history_models/order_history_response.dart';
import '../../../domain/repositories/main_repository.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  OrderHistoryCubit() : super(OrderHistoryLoadingState());

  final MainRepository _mainRepository = MainRepository();

  Future<void> fetchOrderHistory(String request) async {
    try {
      emit(OrderHistoryRequestLoadingState());

      OrderHistory? orderHistoryResponse = await _mainRepository.postOrderHistory(schoolID: request);

      if (orderHistoryResponse != null && orderHistoryResponse.data.orders?.isNotEmpty == true) {
        emit(OrderHistorySuccessState(orderHistoryResponse));
      } else {
        print("Order history fetch failed: Response -> $orderHistoryResponse");
        emit(OrderHistoryErrorState(orderHistoryResponse?.message ?? "No orders found."));
      }
    } on LoginApplicationException catch (error) {
      print("OrderHistoryApplicationException caught: $error");

      final fieldErrors = error.fieldErrors ?? {};
      final nonFieldErrors = error.nonFieldErrors ?? {};
      final generalFieldErrors = error.generalFieldErrors ?? {};

      if (fieldErrors.isNotEmpty) {
        print("Order History Field Errors: $fieldErrors");
        emit(OrderHistoryFieldErrorState(fieldErrors));
      } else if (nonFieldErrors.isNotEmpty) {
        print("Order History Non-Field Errors: $nonFieldErrors");
        emit(OrderHistoryNonFieldErrorState(nonFieldErrors));
      } else if (generalFieldErrors.isNotEmpty) {
        print("Order History General Errors: $generalFieldErrors");
        emit(OrderHistoryGeneralFieldErrorState(generalFieldErrors));
      } else {
        emit(OrderHistoryErrorState("Unexpected error occurred while fetching order history."));
      }
    } catch (error, stackTrace) {
      print("Unhandled order history error: $error");
      print(stackTrace);
      emit(OrderHistoryErrorState("An error occurred while fetching order history. Please try again later."));
    }
  }
}
