class ChangePasswordResponse {
  ChangePasswordResponse({
    required this.detail,
  });

  final String? detail;
  static const String detailKey = "detail";

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      detail: json["detail"],
    );
  }

  Map<String, dynamic> toJson() => {
        "detail": detail,
      };
}
