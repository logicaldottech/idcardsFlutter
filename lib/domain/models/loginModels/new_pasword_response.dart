class NewPasswordResponse {
  final String message;
  final dynamic data; // Can be changed to appropriate type if needed

  NewPasswordResponse({required this.message, this.data});

  // Factory method to create an instance from JSON
  factory NewPasswordResponse.fromJson(Map<String, dynamic> json) {
    return NewPasswordResponse(
      message: json['message'] ?? '',
      data: json['data'], // Keeping dynamic for now
    );
  }

  // Method to convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data,
    };
  }
}




