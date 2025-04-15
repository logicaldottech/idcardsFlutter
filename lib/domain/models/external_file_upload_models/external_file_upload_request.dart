import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ExternalUploadFileRequest {
  final File file;

  ExternalUploadFileRequest({required this.file});

  Future<FormData> toFormData() async {
    // Extract file extension
    String fileExtension = file.path.split('.').last.toLowerCase();

    // Validate supported formats
    if (!["png", "jpg", "jpeg", "svg"].contains(fileExtension)) {
      throw Exception("❌ Invalid file type: $fileExtension. Only PNG, JPG, JPEG, and SVG are allowed.");
    }

    return FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: "uploaded_file.$fileExtension",
        contentType: MediaType('image', fileExtension == "svg" ? "svg+xml" : fileExtension),
      ),
    });
  }
}
