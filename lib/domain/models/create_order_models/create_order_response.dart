class CreateOrderResponse {
  final int? orderId;
  final String? orderStatus;
  final String? orderDate;
  final List<StudentOrder>? students;

  CreateOrderResponse({
    this.orderId,
    this.orderStatus,
    this.orderDate,
    this.students,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      orderId: json['order_id'],
      orderStatus: json['order_status'],
      orderDate: json['order_date'],
      students: (json['students'] as List?)
          ?.map((e) => StudentOrder.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_status': orderStatus,
      'order_date': orderDate,
      'students': students?.map((e) => e.toJson()).toList(),
    };
  }
}

class StudentOrder {
  final String? studentId;
  final String? studentName;
  final String? template;
  final String? imageUrl;
  final String? status;

  StudentOrder({
    this.studentId,
    this.studentName,
    this.template,
    this.imageUrl,
    this.status,
  });

  factory StudentOrder.fromJson(Map<String, dynamic> json) {
    return StudentOrder(
      studentId: json['student_id'],
      studentName: json['student_name'],
      template: json['template'],
      imageUrl: json['image_url'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'template': template,
      'image_url': imageUrl,
      'status': status,
    };
  }
}
