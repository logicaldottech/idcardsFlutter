class EditProfileRequest {
  final String? fullName;
  final String? email;
  final String? logo;

  EditProfileRequest({this.fullName, this.email, this.logo});

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'logo': logo,
    };
  }
}
