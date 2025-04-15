import 'dart:convert';

NewPasswordRequest changeRequest(String str) =>
    NewPasswordRequest.fromJson(json.decode(str));

//String addCommentRequestToJson(LoginRequest data) => json.encode(data.toJson());

class NewPasswordRequest {

  String? old_password;
  String? new_password;

  NewPasswordRequest({


    required this.old_password,
    required this.new_password
  });

  factory NewPasswordRequest.fromJson(Map<String, dynamic> json) =>
      NewPasswordRequest(

        old_password: json["old_password"],


        new_password: json["new_password"]

      );

  Map<String, dynamic> toJson() => {
    "old_password" : old_password,
    "new_password" : new_password
  };
}
