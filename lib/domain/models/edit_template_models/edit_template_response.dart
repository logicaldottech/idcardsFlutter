class EditTemplateResponse {
  final bool success;
  final String message;
  final String templateId;

  EditTemplateResponse({
    required this.success,
    required this.message,
    required this.templateId,
  });

  factory EditTemplateResponse.fromJson(Map<String, dynamic> json) {
    return EditTemplateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      templateId: json['templateId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'templateId': templateId,
    };
  }
}
