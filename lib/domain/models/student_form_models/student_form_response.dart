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
  final List<String>? templateBackFields;
  final Map<String, dynamic> imageFields;
  final Map<String, dynamic>? backImageFields;
  final String templateType;
  final String status;
  final int isDeleted;
  final String orientation;
  final String uploadedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? thumbnailfileNameFront;
  final String? thumbnailfileNameBack;
  final int? isProfessional;
  final String? backFileName;
  final String? type;
  final String? xlsFileName;

  TemplateData({
    required this.id,
    required this.templateName,
    required this.fileName,
    required this.templateFields,
    this.templateBackFields,
    required this.imageFields,
    this.backImageFields,
    required this.templateType,
    required this.status,
    required this.isDeleted,
    required this.orientation,
    required this.uploadedAt,
    this.createdAt,
    this.updatedAt,
    this.thumbnailfileNameFront,
    this.thumbnailfileNameBack,
    this.isProfessional,
    this.backFileName,
    this.type,
    this.xlsFileName,
  });

  factory TemplateData.fromJson(Map<String, dynamic> json) {
    return TemplateData(
      id: json['_id'] as String,
      templateName: json['templateName'] as String,
      fileName: json['fileName'] as String,
      templateFields: List<String>.from(json['templateFields']),
      templateBackFields: json['templateBackFields'] != null
          ? List<String>.from(json['templateBackFields'])
          : null,
      imageFields: json['imageFields'] as Map<String, dynamic>,
      backImageFields: json['backImageFields'] != null
          ? json['backImageFields'] as Map<String, dynamic>
          : null,
      templateType: json['templateType'] as String,
      status: json['status'] as String,
      isDeleted: json['isDeleted'] as int,
      orientation: json['orientation'] as String,
      uploadedAt: json['uploadedAt'] as String,
      createdAt: json['createdAt'] as String?, // May be null if not provided
      updatedAt: json['updatedAt'] as String?, // May be null if not provided
      thumbnailfileNameFront: json['thumbnailfileNameFront'] as String?,
      thumbnailfileNameBack: json['thumbnailfileNameBack'] as String?,
      isProfessional: json['isProfessional'] as int?,
      backFileName: json['backFileName'] as String?,
      type: json['Type'] as String?,
      xlsFileName: json['xlsFileName'] as String?,
    );
  }

  bool get isUserImageAvailable => imageFields['userimg'] == true;
  bool get isSignatureRequired =>
      imageFields['signimg'] == true || backImageFields?['signimg'] == true;
  bool get isLogoRequired =>
      imageFields['logoimg'] == true || backImageFields?['logoimg'] == true;
  bool get isPortrait => orientation != "horizontal";

  String get imageUrl =>
      "https://api.todaystrends.site/thumbnails/$thumbnailfileNameFront";
  String get backImageUrl =>
      "https://api.todaystrends.site/thumbnails/$thumbnailfileNameBack";
  String get edittemplateimageUrl =>
      "https://api.todaystrends.site/templates/$fileName";
  String? get edittemplateBackUrl => backFileName != null
      ? "https://api.todaystrends.site/templates/$backFileName"
      : null;

  String? get xlFileUrl => xlsFileName != null
      ? "https://api.todaystrends.site/externalFiles/$xlsFileName"
      : null;
}
