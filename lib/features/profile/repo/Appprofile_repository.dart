import 'package:dio/dio.dart';
import 'package:kleanitapp/core/constants/Spydo_pref_resources.dart';
import 'package:kleanitapp/core/constants/Sypdo_url_resources.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/Appcustomer_model.dart';

class AppProfileRepository {
  final dio = Dio();

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppPrefResources.USER_ACCESS_TOCKEN);
  }

  Future<AppCustomerModel> fetchProfile() async {
    final token = await _getAccessToken();
    if (token == null) throw Exception("Unauthorized: No access token");
    final url = UrlResources.fetchProfile;
    print("🔵 [FETCH PROFILE]");
    print("➡️ URL: $url");
    print("➡️ Headers: Authorization: Bearer $token");

    final response = await dio.get(UrlResources.fetchProfile, options: Options(headers: {"Authorization": "Bearer $token"}));
    print("✅ Response: ${response.statusCode}");
    print("🟢 Response Body: ${response.data}");

    print("🔵 [Profile Fetch] Full Response: ${response.data}");
    if (response.statusCode == 200) {
      return AppCustomerModel.fromJson(response.data['customer']);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  Future<void> updateProfile(AppCustomerModel customer) async {
    try {
      final token = await _getAccessToken();
      if (token == null) throw Exception("Unauthorized: No access token");
      final url = UrlResources.updateProfile;
      final requestBody = customer.toJson();

      print("🟡 [UPDATE PROFILE]");
      print("➡️ URL: $url");
      print("➡️ Headers: Authorization: Bearer $token");
      print("➡️ Request Body: $requestBody");

      final response = await dio.post(UrlResources.updateProfile, data: customer.toJson(), options: Options(headers: {"Authorization": "Bearer $token"}));
      print("🟢 [Profile Update] Full Response: ${response.data}");
      print("✅ Response: ${response.statusCode}");
      print("🟢 Response Body: ${response.data}");

      if (response.statusCode != 200) {
        throw Exception("Failed to update profile");
      }
    } on DioException catch (e) {
      print("🔴 [Profile Update Error] ${e.response?.data}");

      throw Exception(e.response?.data["message"] ?? e.response?.data["error"] ?? "Failed to Update profile");
    }
  }
}
