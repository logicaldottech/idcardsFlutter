class StudentFormResponse {
  final String message;
  final TemplateData data;

  StudentFormResponse({required this.message, required this.data});

  factory StudentFormResponse.fromJson(Map<String, dynamic> json) {
    return StudentFormResponse(
      message: json['message'],
      data: TemplateData.fromJson(json['data']['template']),
    );
  }


}

class TemplateData {
  final String id;
  final String templateName;
  final String fileName;
  final List<String> templateFields;
  final String templateType;
  final String status;
  final int isDeleted;
  final String orientation;
  final String uploadedAt;
  final String createdAt;
  final String updatedAt;

  TemplateData({
    required this.id,
    required this.templateName,
    required this.fileName,
    required this.templateFields,
    required this.templateType,
    required this.status,
    required this.isDeleted,
    required this.orientation,
    required this.uploadedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TemplateData.fromJson(Map<String, dynamic> json) {
    return TemplateData(
      id: json['_id'],
      templateName: json['templateName'],
      fileName: json['fileName'],
      templateFields: List<String>.from(json['templateFields']),
      templateType: json['templateType'],
      status: json['status'],
      isDeleted: json['isDeleted'],
      orientation: json['orientation'],
      uploadedAt: json['uploadedAt'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
