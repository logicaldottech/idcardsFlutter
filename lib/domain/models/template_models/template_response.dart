class TemplateResponse {
  final String? message;
  final TemplateData? data;

  TemplateResponse({this.message, this.data});

  factory TemplateResponse.fromJson(Map<String, dynamic> json) {
    return TemplateResponse(
      message: json['message'],
      data: json['data'] != null ? TemplateData.fromJson(json['data']) : null,
    );
  }
}

class TemplateData {
  final List<Template>? templates;

  TemplateData({this.templates});

  factory TemplateData.fromJson(Map<String, dynamic> json) {
    return TemplateData(
      templates: (json['templates'] as List?)
          ?.map((e) => Template.fromJson(e))
          .toList(),
    );
  }
}

class Template {
  final String? id;
  final String? templateName;
  final String? fileName;
  final List<String>? templateFields;
  final List<String>? templateBackFields;
  final ImageFields? imageFields;
  final ImageFields? backImageFields;
  final int? isProfessional;
  final String? backFileName;
  final String? templateType;
  final String? xlsFileName;
  final String? type;
  final String? status;
  final int? isDeleted;
  final String? thumbnailfileNameFront;
  final String? thumbnailfileNameBack;
  final String? uploadedAt;
  final String? orientation;
  final String? createdAt;
  final String? updatedAt;

  Template({
    this.id,
    this.templateName,
    this.fileName,
    this.templateFields,
    this.templateBackFields,
    this.imageFields,
    this.backImageFields,
    this.isProfessional,
    this.backFileName,
    this.templateType,
    this.type,
    this.status,
    this.thumbnailfileNameFront,
    this.thumbnailfileNameBack,
    this.isDeleted,
    this.uploadedAt,
    this.orientation,
    this.createdAt,
    this.updatedAt,
    this.xlsFileName,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
        id: json['_id'],
        templateName: json['templateName'],
        fileName: json['fileName'],
        templateFields: (json['templateFields'] as List?)
            ?.map((e) => e.toString())
            .toList(),
        templateBackFields: (json['templateBackFields'] as List?)
            ?.map((e) => e.toString())
            .toList(),
        imageFields: json['imageFields'] != null
            ? ImageFields.fromJson(json['imageFields'])
            : null,
        thumbnailfileNameFront: json['thumbnailfileNameFront'],
        thumbnailfileNameBack: json['thumbnailfileNameBack'],
        backImageFields: json['backImageFields'] != null
            ? ImageFields.fromJson(json['backImageFields'])
            : null,
        isProfessional: json['isProfessional'],
        backFileName: json['backFileName'],
        templateType: json['templateType'],
        type: json['Type'],
        status: json['status'],
        isDeleted: json['isDeleted'],
        uploadedAt: json['uploadedAt'],
        orientation: json['orientation'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        xlsFileName: json['xlsFileName']);
  }

  bool get isPortait => !(orientation == "horizontal");

  String get imageUrl =>
      "https://api.todaystrends.site/thumbnails/$thumbnailfileNameFront";
  String get backImageUrl =>
      "https://api.todaystrends.site/thumbnails/$thumbnailfileNameBack";
  String? get edittemplateimageUrl => fileName != null
      ? "https://api.todaystrends.site/templates/$fileName"
      : null;
  String? get edittemplateBackUrl => backFileName != null
      ? "https://api.todaystrends.site/templates/$backFileName"
      : null;
  // String? get excelFileUrl =
}

class ImageFields {
  final bool? logoImg;
  final bool? userImg;
  final String? id;

  ImageFields({this.logoImg, this.userImg, this.id});

  factory ImageFields.fromJson(Map<String, dynamic> json) {
    return ImageFields(
      logoImg: json['logoimg'],
      userImg: json['userimg'],
      id: json['_id'],
    );
  }
}
