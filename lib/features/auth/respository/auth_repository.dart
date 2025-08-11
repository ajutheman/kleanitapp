// // lib/data/repostories/auth_repository.dart
// import 'package:dio/dio.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:kleanitapp/core/utils/url_resources.dart';
// import 'package:kleanitapp/features/auth/model/models/auth_response_model.dart';
// import 'package:kleanitapp/features/auth/model/models/location_response_model.dart';
// import 'package:kleanitapp/features/auth/model/models/otp_login_response_model.dart';
// import 'package:kleanitapp/features/auth/model/models/otp_verification_response_model.dart';
// import 'package:kleanitapp/services/NetworkService.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../core/constants/pref_resources.dart';
//
// class AuthRepository {
//   final NetworkService networkService;
//
//   AuthRepository({required this.networkService});
//
//   Future<AuthResponse> loginWithGoogle(String idToken) async {
//     try {
//       final data = {"id_token": idToken};
//       Response response = await networkService.post(UrlResources.login, data);
//       if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
//         return AuthResponse.fromJson(response.data);
//       } else {
//         throw Exception("Login failed: ${response.statusCode} - ${response.data}");
//       }
//     } on DioException catch (dioError) {
//       print(UrlResources.login);
//       print(idToken);
//       throw dioError.response?.data;
//     } catch (e) {
//       throw Exception("Login failed: $e");
//     }
//   }
//
//   Future<OTPLoginResponse> loginWithOtp(String mobile) async {
//     try {
//       FormData formData = FormData.fromMap({"mobile": mobile});
//       Response response = await networkService.dio.post(UrlResources.loginOtp, data: formData);
//       if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
//         return OTPLoginResponse.fromJson(response.data);
//       } else {
//         throw Exception("OTP login failed: ${response.statusCode} - ${response.data}");
//       }
//     } on DioError catch (dioError) {
//       throw Exception("OTP login failed: ${dioError.message}");
//     } catch (e) {
//       throw Exception("OTP login failed: $e");
//     }
//   }
//
//   Future<OTPVerificationResponse> verifyOtp(String mobile, String otp) async {
//     try {
//       FormData formData = FormData.fromMap({
//         "mobile": mobile,
//         "otp": otp,
//       });
//       Response response = await networkService.dio.post(UrlResources.verifyOtp, data: formData);
//       if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
//         return OTPVerificationResponse.fromJson(response.data);
//       } else {
//         throw Exception("OTP verification failed: ${response.statusCode} - ${response.data}");
//       }
//     } on DioError catch (dioError) {
//       throw Exception("OTP verification failed: ${dioError.message}");
//     } catch (e) {
//       throw Exception("OTP verification failed: $e");
//     }
//   }
//
//   Future<LocationResponse> setLocation(double latitude, double longitude) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) throw Exception("Unauthorized: No access token");
//       // Check if location services are enabled.
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         throw Exception("Location services are disabled.");
//       }
//       // Check location permissions.
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception("Location permissions are denied.");
//         }
//       }
//       if (permission == LocationPermission.deniedForever) {
//         throw Exception("Location permissions are permanently denied.");
//       }
//
//       // Prepare data payload.
//       final data = {"latitude": latitude, "longitude": longitude};
//       Response response = await networkService.dio.post(
//         UrlResources.setLocation,
//         data: data,
//         options: Options(headers: {"Authorization": "Bearer $token"}),
//       );
//       if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
//         return LocationResponse.fromJson(response.data);
//       } else {
//         throw Exception("Location update failed: ${response.statusCode} - ${response.data}");
//       }
//     } on DioException catch (dioError) {
//       throw Exception("Location update failed: ${dioError.message}");
//     } catch (e) {
//       throw Exception("Location update failed: $e");
//     }
//   }
//
//   Future<String?> _getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
//   }
// }
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:kleanitapp/core/utils/url_resources.dart';
import 'package:kleanitapp/features/auth/model/models/auth_response_model.dart';
import 'package:kleanitapp/features/auth/model/models/location_response_model.dart';
import 'package:kleanitapp/features/auth/model/models/otp_login_response_model.dart';
import 'package:kleanitapp/features/auth/model/models/otp_verification_response_model.dart';
import 'package:kleanitapp/services/NetworkService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/pref_resources.dart';

class AuthRepository {
  final NetworkService networkService;

  AuthRepository({required this.networkService});

  Future<AuthResponse> loginWithGoogle(String idToken) async {
    final url = UrlResources.login;
    final data = {"id_token": idToken};

    try {
      log("➡️ [POST] $url");
      log("📦 Body: $data");

      Response response = await networkService.post(url, data);

      log("✅ Response [${response.statusCode}]: ${response.data}");

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return AuthResponse.fromJson(response.data);
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

  Future<OTPLoginResponse> loginWithOtp(String mobile) async {
    final url = UrlResources.loginOtp;
    final formData = FormData.fromMap({"mobile": mobile});

    try {
      log("➡️ [POST] $url");
      log("📦 Body: ${formData.fields}");

      Response response = await networkService.dio.post(url, data: formData);

      log("✅ Response [${response.statusCode}]: ${response.data}");

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return OTPLoginResponse.fromJson(response.data);
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

  Future<OTPVerificationResponse> verifyOtp(String mobile, String otp) async {
    final url = UrlResources.verifyOtp;
    final formData = FormData.fromMap({"mobile": mobile, "otp": otp});

    try {
      log("➡️ [POST] $url");
      log("📦 Body: ${formData.fields}");

      Response response = await networkService.dio.post(url, data: formData);

      log("✅ Response [${response.statusCode}]: ${response.data}");

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return OTPVerificationResponse.fromJson(response.data);
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

  Future<LocationResponse> setLocation(double latitude, double longitude) async {
    final url = UrlResources.setLocation;
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
        return LocationResponse.fromJson(response.data);
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
    return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
  }
}
