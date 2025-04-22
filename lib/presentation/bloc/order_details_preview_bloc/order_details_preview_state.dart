import 'package:pride/domain/models/order_details_preview_models/order_details_preview_response.dart';

abstract class OrderDetailsPreviewState {}

// State when fetching order details is loading
class OrderDetailsPreviewLoadingState extends OrderDetailsPreviewState {}

// State when order details request is processing
class OrderDetailsPreviewRequestLoadingState extends OrderDetailsPreviewState {}

// ✅ Fixed: Now stores a List<OrderItem> instead of OrderDetailsPreviewResponse
class OrderDetailsPreviewSuccessState extends OrderDetailsPreviewState {
  final List<OrderItem>
      orderData; // Store list of OrderItem instead of full response
  final int currentPage;
  final bool hasMoreData;

  OrderDetailsPreviewSuccessState({
    required this.orderData,
    required this.currentPage,
    required this.hasMoreData,
  });

  @override
  String toString() =>
      'OrderDetailsPreviewSuccessState(orderData: ${orderData.length}, currentPage: $currentPage, hasMoreData: $hasMoreData)';
}

// General error state for order details
class OrderDetailsPreviewErrorState extends OrderDetailsPreviewState {
  final String error;

  OrderDetailsPreviewErrorState(this.error);

  @override
  String toString() => 'OrderDetailsPreviewErrorState(error: $error)';
}

// State for field-specific errors in order details
class OrderDetailsPreviewFieldErrorState extends OrderDetailsPreviewState {
  final Map<String, List<String>> fieldErrors;

  OrderDetailsPreviewFieldErrorState(this.fieldErrors);

  @override
  String toString() =>
      'OrderDetailsPreviewFieldErrorState(fieldErrors: $fieldErrors)';
}

// State for non-field-specific errors in order details
class OrderDetailsPreviewNonFieldErrorState extends OrderDetailsPreviewState {
  final Map<String, List<String>> nonFieldErrors;

  OrderDetailsPreviewNonFieldErrorState(this.nonFieldErrors);

  @override
  String toString() =>
      'OrderDetailsPreviewNonFieldErrorState(nonFieldErrors: $nonFieldErrors)';
}

// State for general field errors in order details
class OrderDetailsPreviewGeneralFieldErrorState
    extends OrderDetailsPreviewState {
  final Map<String, List<String>> generalFieldErrors;

  OrderDetailsPreviewGeneralFieldErrorState(this.generalFieldErrors);

  @override
  String toString() =>
      'OrderDetailsPreviewGeneralFieldErrorState(generalFieldErrors: $generalFieldErrors)';
}
