class EditTemplateRequest {
  final String templateId;
  final List<Map<String, dynamic>> replacements;
  final List<ImageLink> imagelinks;

  EditTemplateRequest({
    required this.templateId,
    required this.replacements,
    required this.imagelinks,
  });

  Map<String, dynamic> toJson() {
    return {
      "templateId": templateId,
      "replacements": replacements,
      "imagelinks": imagelinks.map((image) => image.toJson()).toList(),
    };
  }
}

class ImageLink {
  final String imageId;
  final String imageLink;

  ImageLink({
    required this.imageId,
    required this.imageLink,
  });

  Map<String, dynamic> toJson() {
    return {
      "image_id": imageId,
      "image_link": imageLink,
    };
  }
}
