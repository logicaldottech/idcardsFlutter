import 'dart:convert';
import 'dart:convert';

ProfileRequest profileRequestFromJson(String str) =>
    ProfileRequest.fromJson(json.decode(str));

class ProfileRequest {
  String? profileId;

  ProfileRequest({required this.profileId});

  factory ProfileRequest.fromJson(Map<String, dynamic> json) => ProfileRequest(
    profileId: json["profileId"],
  );

  Map<String, dynamic> toJson() => {
    "profileId": profileId,
  };
}
