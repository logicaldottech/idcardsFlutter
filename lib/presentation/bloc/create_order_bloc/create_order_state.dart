import '../../../domain/models/create_order_models/create_order_response.dart';

abstract class CreateOrderState {}

// State when create order request is loading
class CreateOrderLoadingState extends CreateOrderState {}

// State when create order request is processing
class CreateOrderRequestLoadingState extends CreateOrderState {}

// State for successful order creation with response data
class CreateOrderSuccessState extends CreateOrderState {
  final CreateOrderResponse response;

  CreateOrderSuccessState(this.response);

  @override
  String toString() => 'CreateOrderSuccessState(response: $response)';
}

// State for general order errors
class CreateOrderErrorState extends CreateOrderState {
  final String? error;

  CreateOrderErrorState(this.error);

  @override
  String toString() => 'CreateOrderErrorState(error: $error)';
}

// State for field-specific errors in order creation
class CreateOrderFieldErrorState extends CreateOrderState {
  final Map<String, List<String>>? fieldErrors;

  CreateOrderFieldErrorState(this.fieldErrors);

  @override
  String toString() => 'CreateOrderFieldErrorState(fieldErrors: $fieldErrors)';
}

// State for non-field-specific errors in order creation
class CreateOrderNonFieldErrorState extends CreateOrderState {
  final Map<String, List<String>>? nonFieldErrors;

  CreateOrderNonFieldErrorState(this.nonFieldErrors);
  @override
  String toString() =>
      'CreateOrderNonFieldErrorState(nonFieldErrors: $nonFieldErrors)';
}

// State for general field errors in order creation
class CreateOrderGeneralFieldErrorState extends CreateOrderState {
  final Map<String, List<String>>? generalFieldErrors;
  CreateOrderGeneralFieldErrorState(this.generalFieldErrors);

  @override
  String toString() =>
      'CreateOrderGeneralFieldErrorState(generalFieldErrors: $generalFieldErrors)';
}

class DeleteStudentRecordLoadingState extends CreateOrderState {
  @override
  String toString() => 'DeleteStudentRecordLoadingState';
}

class DeleteStudentRecordSuccessState extends CreateOrderState {
  @override
  String toString() => 'DeleteStudentRecordSuccessState';
}

class DeleteStudentRecordErrorState extends CreateOrderState {
  final String error;

  DeleteStudentRecordErrorState(this.error);

  @override
  String toString() => 'DeleteStudentRecordErrorState(error: $error)';
}

class UpdateImageLoadingState extends CreateOrderState {
  @override
  String toString() => 'UpdateImageLoadingState';
}

class UpdateImageSuccessState extends CreateOrderState {
  @override
  String toString() => 'UpdateImageSuccessState';
}

class UpdateImageErrorState extends CreateOrderState {
  final String error;

  UpdateImageErrorState(this.error);

  @override
  String toString() => 'UpdateImageErrorState(error: $error)';
}
