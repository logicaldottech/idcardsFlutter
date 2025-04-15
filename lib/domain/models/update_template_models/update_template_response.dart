class EditTemplateResponse {
  final String message;
  final List<ProcessedFile> processedFiles;

  EditTemplateResponse({
    required this.message,
    required this.processedFiles,
  });

  factory EditTemplateResponse.fromJson(Map<String, dynamic> json) {
    return EditTemplateResponse(
      message: json['message'],
      processedFiles: (json['data']['processedFiles'] as List)
          .map((file) => ProcessedFile.fromJson(file))
          .toList(),
    );
  }
}

class ProcessedFile {
  final int index;
  final String fileName;
  final String filePath;

  ProcessedFile({
    required this.index,
    required this.fileName,
    required this.filePath,
  });

  factory ProcessedFile.fromJson(Map<String, dynamic> json) {
    return ProcessedFile(
      index: json['index'],
      fileName: json['fileName'],
      filePath: json['filePath'],
    );
  }
}
