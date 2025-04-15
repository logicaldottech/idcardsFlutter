/*class LoginRequest{

  String? email;
  String? password;
  LoginRequest(this.email, this.password);
}*/

import 'dart:convert';

LoginRequest loginRequestFromJson(String str) =>
    LoginRequest.fromJson(json.decode(str));

//String addCommentRequestToJson(LoginRequest data) => json.encode(data.toJson());

class LoginRequest {
  String? email;
  String? password;
  String? deviceToken;
  int? deviceType;

  LoginRequest({
    required this.email,
    required this.password,
    required this.deviceToken,
    required this.deviceType,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        email: json["email"],
        password: json["password"],
        deviceType: json["deviceType"],
        deviceToken: json["deviceToken"]



      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
        "deviceType" : deviceType,
         "deviceToken" : deviceToken
      };

  @override
  String toString() {
    return 'LoginRequest(email: $email, password: $password, deviceToken: $deviceToken, deviceType: $deviceType)';
  }
}
