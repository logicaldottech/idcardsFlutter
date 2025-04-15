class StudentFormRequest {
  final String id;

  StudentFormRequest({required this.id});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
    };
  }
}
