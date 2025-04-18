import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:untitled/domain/models/external_file_upload_models/external_file_upload_request.dart';
import 'package:untitled/domain/models/external_file_upload_models/external_file_upload_response.dart';

import '../../data/data_sources/local/preference_utils.dart';
import '../../data/data_sources/remote/network/api_service.dart';
import '../../utils/app_constants.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart'; // ✅ Ensure this is imported
import '../exceptions/login_exception.dart';
import '../models/create_order_models/create_order_request.dart';
import '../models/create_order_models/create_order_response.dart';
import '../models/edit_profile_models/edit_profile_request.dart';
import '../models/edit_profile_models/edit_profile_response.dart';
import '../models/edit_template_models/edit_template_request.dart';
import '../models/edit_template_models/edit_template_response.dart';
import '../models/log_out_models/log_out_request.dart';
import '../models/log_out_models/log_out_response.dart';
import '../models/loginModels/LoginResponse.dart';
import '../models/loginModels/change_password_request.dart';
import '../models/loginModels/change_password_response.dart';
import '../models/loginModels/login_request.dart';
import '../models/loginModels/new_password_request.dart';
import '../models/loginModels/new_pasword_response.dart';
import '../models/order_details_preview_models/order_details_preview_response.dart';
import '../models/order_history_models/order_history_response.dart';
import '../models/otpModels/otp_request.dart';
import '../models/otpModels/otp_response.dart';
import '../models/profile_models/profile_request.dart';
import '../models/profile_models/profile_response.dart';
import '../models/student_form_models/student_form_request.dart';
import '../models/student_form_models/student_form_response.dart';
import '../models/template_models/template_response.dart';

class MainRepository {
  final ApiService apiService = ApiService();

  Future<ChangePasswordResponse> postChangePassword(
      ChangePasswordRequest request) async {
    var data = request.toJson();
    try {
      final response = await apiService.sendRequest
          .post(ApiService.newPasswordResponse, data: jsonEncode(data));
      return ChangePasswordResponse.fromJson(response.data);
    } catch (e) {
      throw LoginExceptionHandler.handleException(e);
    }
  }

  Future<LoginResponse> postLogin(LoginRequest request) async {
    var data = request.toJson();

    try {
      final response = await apiService.sendRequest
          .post(ApiService.login, data: jsonEncode(data));
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      throw LoginExceptionHandler.handleException(e);
    }
  }

  Future<NewPasswordResponse> postNewPassword(
      NewPasswordRequest request) async {
    var data = request.toJson();
    try {
      final response = await apiService.sendRequest
          .post(ApiService.newPasswordResponse, data: jsonEncode(data));
      return NewPasswordResponse.fromJson(response.data);
    } catch (e) {
      throw LoginExceptionHandler.handleException(e);
    }
  }

  Future<TemplateResponse> fetchTemplates() async {
    try {
      final response =
          await apiService.sendRequest.post(ApiService.templateResponse);
      return TemplateResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch templates: $e');
    }
  }

  Future<StudentFormResponse> postStudentForm(
      StudentFormRequest request) async {
    var data = request.toJson();

    try {
      final response = await apiService.sendRequest
          .post(ApiService.studentFormResponse, data: jsonEncode(data));
      return StudentFormResponse.fromJson(response.data);
    } catch (e) {
      throw LoginExceptionHandler.handleException(e);
    }
  }

  Future<ProfileResponse> fetchProfile() async {
    try {
      final response =
          await apiService.sendRequest.get(ApiService.profileResponse);
      print("profile ${response}");
      return ProfileResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<CreateOrderResponse> postCreateOrder(
      CreateOrderRequest request) async {
    var data = request.toJson();

    try {
      final response = await apiService.sendRequest
          .post(ApiService.createOrderResponse, data: jsonEncode(data));

      return CreateOrderResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<OrderHistory> postOrderHistory({required String schoolID}) async {
    try {
      final response = await apiService.sendRequest.post(
          ApiService.orderHistoryResponse,
          data: {"schoolId": schoolID}); // Passing key in the request body);
      print("profile ${response}");
      return OrderHistory.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<LogoutResponse> logout(LogoutRequest request) async {
    var data = request.toJson();
    try {
      final response = await apiService.sendRequest
          .post(ApiService.logout, data: jsonEncode(data));
      print("logoutResponse ${response}");
      if (response.data != null) {
        await PreferencesUtil.clear();
        // WebSocketService().close();
        return LogoutResponse.fromJson(response.data);
      } else {
        throw Exception("Invalid data format received");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<EditTemplateResponse> postEditTemplate(
      EditTemplateRequest request, String schoolId) async {
    try {
      // Ensure the file exists before sending
      File file = File(request.template.path);
      if (!file.existsSync()) {
        throw Exception(
            "❌ File does not exist at path: ${request.template.path}");
      }

      // 🔹 Read the HTML content and print it before uploading
      String fileContents = file.readAsStringSync();
      print("📄 File HTML Contents:\n$fileContents");

      // Prepare FormData with schoolId and template file
      FormData formData = FormData.fromMap({
        "schoolId": schoolId, // ✅ Added schoolId to the request
        "template": await MultipartFile.fromFile(
          request.template.path,
          filename: "modified_template.html",
          contentType:
              MediaType('text', 'html'), // ✅ Ensuring correct file type
        ),
        if (request.templateBack != null)
          'templateBack': await MultipartFile.fromFile(
            request.templateBack!.path,
            filename: "modified_template_back.html", // Use a relevant filename
            contentType: MediaType('text', 'html'),
          ),
        'thumbnailFront': MultipartFile.fromBytes(
          request.frontImage,
          filename: "${DateTime.now().millisecondsSinceEpoch}_front.png",
          contentType: MediaType('image', 'png'),
        ),
        if (request.backImage != null)
          'thumbnailBack': MultipartFile.fromBytes(
            request.backImage!,
            filename: "${DateTime.now().millisecondsSinceEpoch}_back.png",
            contentType: MediaType('image', 'png'),
          )
      });

      // Send request
      final response = await apiService.sendRequest.post(
        ApiService.updateTemplateResponse,
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      print("✅ File uploaded successfully: ${response.data}");
      return EditTemplateResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      print("❌ File upload failed: $e");
      print("🛠 StackTrace: $stackTrace"); // ✅ Debugging info
      throw Exception('Error uploading template: $e');
    }
  }

  Future<ExternalUploadFileResponse> uploadFile(
      ExternalUploadFileRequest request) async {
    try {
      FormData formData = await request.toFormData();

      final response = await apiService.sendRequest.post(
        ApiService
            .uploadExternalFileResponse, // Replace with your actual API endpoint
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      print("✅ File uploaded successfully: ${response.data}");
      return ExternalUploadFileResponse.fromJson(response.data);
    } catch (e) {
      print("❌ Upload failed: $e");
      throw Exception('Error uploading file: $e');
    }
  }

  Future<OrderDetailsPreviewResponse> fetchOrderById({
    required String orderId,
    required int page,
    required int limit,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'orderId': orderId,
        // Static search value
      };

      final response = await apiService.sendRequest.get(
        ApiService.fetchOrderById,
        queryParameters: queryParams, // Properly formatted query parameters
      );

      print("fetchOrderResponse: ${response.data}");
      return OrderDetailsPreviewResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching order details: $e');
    }
  }

  Future<EditProfileResponse> postEditProfile(
      EditProfileRequest request) async {
    var data = request.toJson();

    try {
      final response = await apiService.sendRequest
          .post(ApiService.editProfileResponse, data: jsonEncode(data));

      return EditProfileResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }
}
