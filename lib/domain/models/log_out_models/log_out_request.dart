class LogoutRequest {
  final String deviceToken;

  LogoutRequest({required this.deviceToken});

  factory LogoutRequest.fromJson(Map<String, dynamic> json) {
    return LogoutRequest(
      deviceToken: json['deviceToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceToken': deviceToken,
    };
  }
}