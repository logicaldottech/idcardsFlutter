import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/exceptions/login_exception.dart';
import '../../../domain/models/order_details_preview_models/order_details_preview_response.dart';
import '../../../domain/repositories/main_repository.dart';
import 'order_details_preview_state.dart';

class OrderDetailsPreviewCubit extends Cubit<OrderDetailsPreviewState> {
  OrderDetailsPreviewCubit() : super(OrderDetailsPreviewLoadingState());

  final MainRepository _mainRepository = MainRepository();
  int _currentPage = 1;
  int _totalPages = 1;
  int _limit = 3; // Default limit
  bool _hasMoreData = true;
  bool isPortrait = false;
  bool isLoading = false;
  List<OrderItem> _orderData = []; // List to store fetched order items

  Future<void> fetchOrderDetails(
      {required String orderId, bool isLoadMore = false}) async {
    if (isLoading) return;
    isLoading = true;
    if (!isLoadMore) {
      _currentPage = 1;
      _hasMoreData = true;
      _orderData.clear();
      emit(OrderDetailsPreviewRequestLoadingState());
    }

    if (!_hasMoreData) return; // Stop fetching if no more data available

    try {
      final response = await _mainRepository.fetchOrderById(
        orderId: orderId,
        page: _currentPage,
        limit: _limit,
      );

      if (response.data?.data != null) {
        _orderData.addAll(response.data!.data!); // Append new data
      }
      isPortrait = response.data?.isPortrait ?? false;
      // **Update pagination based on API response**
      _totalPages = response.data?.pagination?.totalPages ?? 1;
      _limit = response.data?.pagination?.limit ?? 3;
      _currentPage = response.data?.pagination?.currentPage ?? _currentPage;

      // **Determine if more data exists**
      _hasMoreData = _currentPage < _totalPages;

      emit(OrderDetailsPreviewSuccessState(
        orderData: _orderData,
        currentPage: _currentPage,
        hasMoreData: _hasMoreData,
      ));

      // Move to the next page **only if there’s more data**
      if (_hasMoreData) {
        _currentPage++;
      }
    } on LoginApplicationException catch (error) {
      _handleLoginException(error);
    } catch (error, stackTrace) {
      print("Unhandled order details preview error: $error");
      print(stackTrace);
      emit(OrderDetailsPreviewErrorState(
          "An error occurred. Please try again."));
    }
    isLoading = false;
  }

  void _handleLoginException(LoginApplicationException error) {
    final fieldErrors = error.fieldErrors ?? {};
    final nonFieldErrors = error.nonFieldErrors ?? {};
    final generalFieldErrors = error.generalFieldErrors ?? {};

    if (fieldErrors.isNotEmpty) {
      emit(OrderDetailsPreviewFieldErrorState(fieldErrors));
    } else if (nonFieldErrors.isNotEmpty) {
      emit(OrderDetailsPreviewNonFieldErrorState(nonFieldErrors));
    } else if (generalFieldErrors.isNotEmpty) {
      emit(OrderDetailsPreviewGeneralFieldErrorState(generalFieldErrors));
    } else {
      emit(OrderDetailsPreviewErrorState(
          "Unexpected error occurred while fetching order details."));
    }
  }
}
