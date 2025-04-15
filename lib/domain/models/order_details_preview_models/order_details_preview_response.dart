class OrderDetailsPreviewResponse {
  final String? message;
  final OrderData? data;

  OrderDetailsPreviewResponse({this.message, this.data});

  factory OrderDetailsPreviewResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailsPreviewResponse(
      message: json['message'] as String?,
      data: json['data'] != null ? OrderData.fromJson(json['data']) : null,
    );
  }
}

class OrderData {
  final String? orderId;
  final List<OrderItem>? data;
  final Pagination? pagination;

  OrderData({this.orderId, this.data, this.pagination});

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      orderId: json['OrderId'] as String?,
      data: (json['Data'] as List?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList(),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class OrderItem {
  final int? srNo;
  final String? processedFilesWatermarked;
  final String? studentName;

  OrderItem({this.srNo, this.processedFilesWatermarked, this.studentName});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      srNo: json['SrNo'] as int?,
      processedFilesWatermarked: json['processedFilesWatermarked'] as String?,
      studentName: json['StudentName'] as String?,
    );
  }
}

class Pagination {
  final int? totalItems;
  final int? totalPages;
  final int? currentPage;
  final int? limit;

  Pagination({this.totalItems, this.totalPages, this.currentPage, this.limit});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalItems: json['totalItems'] as int?,
      totalPages: json['totalPages'] as int?,
      currentPage: json['currentPage'] as int?,
      limit: json['limit'] as int?,
    );
  }
}
