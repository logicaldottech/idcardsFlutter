import '../../../domain/models/order_history_models/order_history_response.dart';

abstract class OrderHistoryState {}

// State when order history request is loading
class OrderHistoryLoadingState extends OrderHistoryState {}

// State when order history request is processing
class OrderHistoryRequestLoadingState extends OrderHistoryState {}

// State for successful order history retrieval with response data
class OrderHistorySuccessState extends OrderHistoryState {
  final OrderHistory response;

  OrderHistorySuccessState(this.response);

  @override
  String toString() => 'OrderHistorySuccessState(response: $response)';
}

// State for general order history errors
class OrderHistoryErrorState extends OrderHistoryState {
  final String? error;

  OrderHistoryErrorState(this.error);

  @override
  String toString() => 'OrderHistoryErrorState(error: $error)';
}

// State for field-specific errors in order history retrieval
class OrderHistoryFieldErrorState extends OrderHistoryState {
  final Map<String, List<String>>? fieldErrors;

  OrderHistoryFieldErrorState(this.fieldErrors);

  @override
  String toString() => 'OrderHistoryFieldErrorState(fieldErrors: $fieldErrors)';
}

// State for non-field-specific errors in order history retrieval
class OrderHistoryNonFieldErrorState extends OrderHistoryState {
  final Map<String, List<String>>? nonFieldErrors;

  OrderHistoryNonFieldErrorState(this.nonFieldErrors);

  @override
  String toString() => 'OrderHistoryNonFieldErrorState(nonFieldErrors: $nonFieldErrors)';
}

// State for general field errors in order history retrieval
class OrderHistoryGeneralFieldErrorState extends OrderHistoryState {
  final Map<String, List<String>>? generalFieldErrors;

  OrderHistoryGeneralFieldErrorState(this.generalFieldErrors);

  @override
  String toString() => 'OrderHistoryGeneralFieldErrorState(generalFieldErrors: $generalFieldErrors)';
}