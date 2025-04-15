class LogoutResponse {
  final String message;
  final dynamic data;

  LogoutResponse({required this.message, this.data});

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data,
    };
  }
}
