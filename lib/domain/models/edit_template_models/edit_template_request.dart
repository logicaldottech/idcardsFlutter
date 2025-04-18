import 'dart:io';

import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';

class EditTemplateRequest {
  final File template;
  final File? templateBack;
  final Uint8List frontImage;
  final Uint8List? backImage;

  EditTemplateRequest(
      {this.templateBack,
      required this.frontImage,
      this.backImage,
      required this.template});

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'template': await MultipartFile.fromFile(
        template.path,
        filename: "modified_template.html", // Use a relevant filename
      ),
      if (templateBack != null)
        'templateBack': await MultipartFile.fromFile(
          templateBack!.path,
          filename: "modified_template_back.html", // Use a relevant filename
        ),
      'thumbnailFront': MultipartFile.fromBytes(frontImage),
      if (backImage != null)
        'thumbnailBack': MultipartFile.fromBytes(backImage!)
    });
  }
}
