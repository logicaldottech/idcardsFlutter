/*class LoginRequest{

  String? email;
  String? password;
  LoginRequest(this.email, this.password);
}*/

import 'dart:convert';

ChangePasswordRequest changeRequest(String str) =>
    ChangePasswordRequest.fromJson(json.decode(str));

//String addCommentRequestToJson(LoginRequest data) => json.encode(data.toJson());

class ChangePasswordRequest {

  String? email;

  ChangePasswordRequest({

    required this.email,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      ChangePasswordRequest(

        email: json["email"],

      );

  Map<String, dynamic> toJson() => {
        "email": email,
  };
}
