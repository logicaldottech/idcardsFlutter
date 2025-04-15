class ExternalUploadFileResponse {
  final String message;
  final String fileName;

  ExternalUploadFileResponse({required this.message, required this.fileName});

  factory ExternalUploadFileResponse.fromJson(Map<String, dynamic> json) {
    return ExternalUploadFileResponse(
      message: json["message"] ?? "Unknown response",
      fileName: json["data"]?["fileName"] ?? "",
    );
  }
}
