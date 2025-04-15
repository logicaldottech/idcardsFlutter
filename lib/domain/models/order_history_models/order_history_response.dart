import 'dart:convert';

class OrderHistory {
  final String message;
  final OrderData data;

  OrderHistory({
    required this.message,
    required this.data,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      message: json['message'],
      data: OrderData.fromJson(json['data']),
    );
  }
}

class OrderData {
  final List<Order> orders;
  final int totalOrders;
  final int totalPages;
  final int currentPage;
  final int limit;

  OrderData({
    required this.orders,
    required this.totalOrders,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      orders: (json['orders'] as List)
          .map((order) => Order.fromJson(order))
          .toList(),
      totalOrders: json['totalOrders'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      limit: json['limit'],
    );
  }
}

class Order {
  final String id;
  final String schoolName;
  final String templateName;
  final String orderType;

  final String status;
  final int totalItems;
  final DateTime createdAt;
  final String? thumbnailfileNameFront;

  Order({
    required this.id,
    required this.schoolName,
    required this.templateName,
    required this.orderType,

    required this.status,
    required this.totalItems,
    required this.createdAt,
    required this.thumbnailfileNameFront
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      schoolName: json['schoolName'],
      templateName: json['templateName'],
      orderType: json['orderType'],
      thumbnailfileNameFront: json['thumbnailfileNameFront'],

      status: json['status'],
      totalItems: json['totalItems'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// Sample usage:
// final response = OrderHistoryResponse.fromJson(jsonDecode(jsonString));
