import 'dart:convert';


class LoginResponse {
  final String message;
  final LoginData data;

  LoginResponse({required this.message, required this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      data: LoginData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

class LoginData {
  final String token;
  final int isAdminPassword;
  final String schoolId;

  LoginData({required this.token, required this.isAdminPassword, required this.schoolId});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] ?? '',
      isAdminPassword: json['isAdminPassword'] ?? 0,
      schoolId: json['schoolId']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'isAdminPassword': isAdminPassword,
      'schoolId' : schoolId
    };
  }
}
