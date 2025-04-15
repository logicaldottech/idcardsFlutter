class CreateOrderRequest {
  final String schoolId;
  final String templateId;
  final String orderType;
  final List<Map<String, dynamic>>? orderData;


  CreateOrderRequest({
    required this.schoolId,
    required this.templateId,
    required this.orderType,
    this.orderData,

  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) {
    return CreateOrderRequest(
      schoolId: json['schoolId'] ?? '',
      templateId: json['templateId'] ?? '',
      orderType: json['orderType'] ?? '',
      orderData: (json['orderData'] as List<dynamic>?)
          ?.map((item) => Map<String, dynamic>.from(item))
          .toList(),

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schoolId': schoolId,
      'templateId': templateId,
      'orderType': orderType,
      'orderData': orderData, // Will be null if not provided

    };
  }

  @override
  String toString() {
    return 'CreateOrderRequest(schoolId: $schoolId, templateId: $templateId, orderType: $orderType, orderData: ${orderData?.toString()})';
  }
}
