import 'dart:convert';

OtpRequest changeRequest(String str) =>
    OtpRequest.fromJson(json.decode(str));

//String addCommentRequestToJson(LoginRequest data) => json.encode(data.toJson());

class OtpRequest {

  int? otp;

  OtpRequest({required this.otp,});

  factory OtpRequest.fromJson(Map<String, dynamic> json) =>
      OtpRequest(
        otp: json["otp"],);

  Map<String, dynamic> toJson() => {
    "otp": otp,
  };
}
