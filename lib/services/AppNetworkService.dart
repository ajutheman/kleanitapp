// lib/services/network_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/url_resources.dart';

class AppNetworkService {
  late Dio dio;

  AppNetworkService() {
    BaseOptions options = BaseOptions(
      baseUrl: AppUrlResources.AppbaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    );
    dio = Dio(options);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          String? token = prefs.getString("user_access_token");
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
        onError: (DioError error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(endpoint, queryParameters: queryParameters);
  }

  Future<Response> post(String endpoint, dynamic data, {Options? options}) async {
    return await dio.post(endpoint, data: data, options: options);
  }
}
