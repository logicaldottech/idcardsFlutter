class CustomDioException implements Exception {
  late int? statusCode;
  late String? message;
  late dynamic response;

  CustomDioException({this.statusCode, this.message, this.response});

  factory CustomDioException.fromDioError(dioError) {
    int? statusCode;
    String message;
    dynamic response;

    if (dioError.response != null) {
      statusCode = dioError.response!.statusCode;
      message = dioError.response!.statusMessage ?? '';
      response = dioError.response!.data;
    } else {
      statusCode = -1; // DioErrorType.DEFAULT
      message = dioError.error.toString();
      response = null;
    }

    return CustomDioException(
      statusCode: statusCode,
      message: message,
      response: response,
    );
  }

  @override
  String toString() {
    return 'CustomDioException - Status Code: $statusCode, Message: $message, Response: $response';
  }
}
