class EditProfileResponse {
  final String? message;
  final ProfileData? data;

  EditProfileResponse({this.message, this.data});

  factory EditProfileResponse.fromJson(Map<String, dynamic> json) {
    return EditProfileResponse(
      message: json['message'] as String?,
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class ProfileData {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;
  final String? logo;
  final String? updatedAt;

  ProfileData({
    this.fullName,
    this.email,
    this.phone,
    this.address,
    this.logo,
    this.updatedAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      logo: json['logo'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'logo': logo,
      'updatedAt': updatedAt,
    };
  }
}
