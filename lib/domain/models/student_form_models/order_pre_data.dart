import 'dart:convert';

class OrderPreData {
  final int id;
  final Map<String, dynamic> data;
  final String? logoUrl;
  final String? signatureUrl;
  OrderPreData(
      {required this.id,
      required this.data,
      required this.logoUrl,
      required this.signatureUrl});

  factory OrderPreData.fromJson(Map<String, dynamic> json) {
    return OrderPreData(
      id: json['id'],
      data: jsonDecode(json['data']),
      logoUrl: json['logo'],
      signatureUrl: json['signature'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> dt = Map.from(data);
    if (logoUrl != null) {
      dt['https://api.todaystrends.site/externalFiles/logo.png'] = logoUrl;
    }
    if (signatureUrl != null) {
      dt['https://api.todaystrends.site/externalFiles/signature.png'] =
          signatureUrl;
    }
    return dt;
  }

  bool get hasUserImage {
    return data['https://api.todaystrends.site/externalFiles/userpic.png'] !=
        null;
  }
}
