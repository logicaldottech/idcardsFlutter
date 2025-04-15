import 'dart:io';


import 'dart:io';
import 'package:dio/dio.dart';

class EditTemplateRequest {
  final File template;

  EditTemplateRequest({required this.template});

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'template': await MultipartFile.fromFile(
        template.path,
        filename: "modified_template.html", // Use a relevant filename
      ),
    });
  }
}

