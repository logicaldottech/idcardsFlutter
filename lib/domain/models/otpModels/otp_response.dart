class OtpResponse {
  OtpResponse({
    required this.detail,
  });

  final String? detail;
  static const String detailKey = "detail";

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      detail: json["detail"],
    );
  }

  Map<String, dynamic> toJson() => {
    "detail": detail,
  };
}
