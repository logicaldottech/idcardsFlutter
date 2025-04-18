import 'dart:convert';

class ProfileResponse {
  final String message;
  final ProfileDetail data;

  ProfileResponse({required this.message, required this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      message: json['message'],
      data: ProfileDetail.fromJson(json['data']['profileDetail']),
    );
  }
}

class ProfileDetail {
  final Wallet wallet;
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final int type;
  final int isAdminPassword;
  final List<Device> devices;
  final List<dynamic> subscriptions;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? logo;

  ProfileDetail({
    required this.wallet,
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.type,
    required this.isAdminPassword,
    required this.devices,
    required this.subscriptions,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.logo
  });

  factory ProfileDetail.fromJson(Map<String, dynamic> json) {
    return ProfileDetail(
      wallet: Wallet.fromJson(json['wallet']),
      id: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      type: json['type'],
      isAdminPassword: json['isAdminPassword'],
      devices: (json['devices'] as List).map((e) => Device.fromJson(e)).toList(),
      subscriptions: json['subscriptions'] ?? [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      version: json['__v'],
      logo: json['logo']
    );
  }
}

class Wallet {
  final int balance;
  final List<dynamic> transactions;

  Wallet({required this.balance, required this.transactions});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      balance: json['balance'],
      transactions: json['transactions'] ?? [],
    );
  }
}

class Device {
  final String deviceToken;
  final String deviceType;
  final int tokenVersion;
  final String id;

  Device({
    required this.deviceToken,
    required this.deviceType,
    required this.tokenVersion,
    required this.id,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceToken: json['deviceToken'],
      deviceType: json['deviceType'].toString(),
      tokenVersion: json['tokenVersion'],
      id: json['_id'],
    );
  }
}
