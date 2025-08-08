import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/pref_resources.dart';
import '../../../core/constants/url_resources.dart';

class TokenRepository {
  final dio = Dio();

  Future<bool> updateToken({required String fcmToken}) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Unauthorized: Access token not found");
      }

      final payload = {"fcm_token": fcmToken};

      final response = await dio.post(
        UrlResources.tokenUpdate,
        data: jsonEncode(payload),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Failed to update token: ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? "Failed to update token");
    } catch (e) {
      throw Exception("Error update token: $e");
    }
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
  }
}
