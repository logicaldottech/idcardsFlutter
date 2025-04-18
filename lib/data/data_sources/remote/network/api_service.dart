import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:untitled/main.dart';
import 'package:untitled/navigation/page_routes.dart';
import 'package:untitled/utils/vl_toast.dart';

import '../../../../utils/app_constants.dart';
import '../../local/preference_utils.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService._privateConstructor() {
    initApiService();
  }

  static final ApiService _instance = ApiService._privateConstructor();

  factory ApiService() {
    return _instance;
  }

  static const String devUrl = "https://api.todaystrends.site/apis/v1/";

  static String getHtmlTemplateUrl(String fileName) =>
      'https://api.todaystrends.site/templates/$fileName';

  /// API Endpoints
  static const String login = "login";
  static const String newPasswordResponse = "password_change";
  static const String logout = "logout/";
  static const String templateResponse = "fetch_templates/";
  static const String studentFormResponse = "fetch_template_by_id";
  static const String profileResponse = "fetch_profile";
  static const String createOrderResponse = "create_order";
  static const String editProfileResponse = "edit_profile";
  static const String updateTemplateResponse = "upload_custom_template";
  static const String orderHistoryResponse = "fetch_orders";
  static const String uploadExternalFileResponse = "upload_external_file";
  static const String fetchOrderById = "fetch_order_by_id";

  void initApiService() {
    _dio.options.baseUrl = devUrl;
    _dio.options.headers['Content-Type'] = 'application/json';

    _dio.interceptors
      ..add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Retrieve token dynamically before every request
          String? token =
              await PreferencesUtil.getString(AppConstants.authToken);
          print("tokenvalue ${token}");
          options.headers['Authorization'] = 'Bearer $token';

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            PreferencesUtil.clear();
            Navigator.of(navigatorKey.currentContext!)
                .pushNamedAndRemoveUntil(PageRoutes.login, (route) => false);
            ToastUtils.showErrorToast('Session Expired!. Please login again.');
          }
          return handler.next(e);
        },
      ))
      ..add(PrettyDioLogger(
        request: true,
        error: true,
        requestBody: true,
        requestHeader: false,
        responseHeader: false,
        responseBody: true,
        logPrint: (Object object) {
          if (kDebugMode) {
            log(object.toString());
          }
        },
      ));
  }

  /// Expose the configured Dio instance
  Dio get sendRequest => _dio;
}
