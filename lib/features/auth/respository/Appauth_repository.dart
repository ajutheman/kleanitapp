
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:kleanitapp/core/utils/url_resources.dart';
import 'package:kleanitapp/features/auth/model/models/Appauth_response_model.dart';
import 'package:kleanitapp/features/auth/model/models/Applocation_response_model.dart';
import 'package:kleanitapp/features/auth/model/models/Appotp_login_response_model.dart';
import 'package:kleanitapp/features/auth/model/models/Appotp_verification_response_model.dart';
import 'package:kleanitapp/services/AppNetworkService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/Spydo_pref_resources.dart';

class AppAuthRepository {
  final AppNetworkService networkService;

  AppAuthRepository({required this.networkService});

  Future<AppAuthResponse> loginWithGoogle(String idToken) async {
    final url = AppUrlResources.Applogin;
    final data = {"id_token": idToken};

    try {
      log("➡️ [POST] $url");
      log("📦 Body: $data");

      Response response = await networkService.post(url, data);

      log("✅ Response [${response.statusCode}]: ${response.data}");

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return AppAuthResponse.fromJson(response.data);
      } else {
        throw Exception("Login failed: ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (dioError) {
      log("❌ DioException at $url\n${dioError.message}");
      log("🔴 Response: ${dioError.response?.data}");
      throw dioError.response?.data;
    } catch (e) {
      log("❌ General Exception: $e");
      throw Exception("Login failed: $e");
    }
  }

  Future<AppOTPLoginResponse> loginWithOtp(String mobile) async {
    final url = AppUrlResources.ApploginOtp;
    final formData = FormData.fromMap({"mobile": mobile});

    try {
      log("➡️ [POST] $url");
      log("📦 Body: ${formData.fields}");

      Response response = await networkService.dio.post(url, data: formData);

      log("✅ Response [${response.statusCode}]: ${response.data}");

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return AppOTPLoginResponse.fromJson(response.data);
      } else {
        throw Exception("OTP login failed: ${response.statusCode} - ${response.data}");
      }
    } on DioError catch (dioError) {
      log("❌ DioError at $url\n${dioError.message}");
      log("🔴 Response: ${dioError.response?.data}");
      throw Exception("OTP login failed: ${dioError.message}");
    } catch (e) {
      log("❌ General Exception: $e");
      throw Exception("OTP login failed: $e");
    }
  }

  Future<AppOTPVerificationResponse> verifyOtp(String mobile, String otp) async {
    final url = AppUrlResources.AppverifyOtp;
    final formData = FormData.fromMap({"mobile": mobile, "otp": otp});

    try {
      log("➡️ [POST] $url");
      log("📦 Body: ${formData.fields}");

      Response response = await networkService.dio.post(url, data: formData);

      log("✅ Response [${response.statusCode}]: ${response.data}");

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return AppOTPVerificationResponse.fromJson(response.data);
      } else {
        throw Exception("OTP verification failed: ${response.statusCode} - ${response.data}");
      }
    } on DioError catch (dioError) {
      log("❌ DioError at $url\n${dioError.message}");
      log("🔴 Response: ${dioError.response?.data}");
      throw Exception("OTP verification failed: ${dioError.message}");
    } catch (e) {
      log("❌ General Exception: $e");
      throw Exception("OTP verification failed: $e");
    }
  }

  Future<AppLocationResponse> setLocation(double latitude, double longitude) async {
    final url = AppUrlResources.AppsetLocation;
    final token = await _getAccessToken();
    final data = {"latitude": latitude, "longitude": longitude};

    if (token == null) throw Exception("Unauthorized: No access token");

    try {
      log("➡️ [POST] $url");
      log("📦 Body: $data");
      log("🔐 Headers: Bearer $token");

      Response response = await networkService.dio.post(url, data: data, options: Options(headers: {"Authorization": "Bearer $token"}));

      log("✅ Response [${response.statusCode}]: ${response.data}");

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return AppLocationResponse.fromJson(response.data);
      } else {
        throw Exception("Location update failed: ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (dioError) {
      log("❌ DioError at $url\n${dioError.message}");
      log("🔴 Response: ${dioError.response?.data}");
      throw Exception("Location update failed: ${dioError.message}");
    } catch (e) {
      log("❌ General Exception: $e");
      throw Exception("Location update failed: $e");
    }
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppPrefResources.USER_ACCESS_TOCKEN);
  }
}
