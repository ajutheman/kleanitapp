import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../modle/Appcategory_detail_model.dart';

class AppCategoryDetailRepository {
  final String baseUrl = "https://backend.kleanit.ae/api/customer/categorys/list-services";

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_access_token") ?? "";
  }

  Future<AppCategoryDetailResponse> fetchCategoryDetails(int mainCategoryId, String type) async {
    // Build URL with query parameters as before.
    final url = Uri.parse("$baseUrl?type=$type&main_category_id=$mainCategoryId");

    String token = await _getToken();
    log('SHamil');
    log("$baseUrl?type=$type&main_category_id=$mainCategoryId");
    log(token);
    final response = await http.post(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json", "Content-Type": "application/json"},
      // Send an empty JSON body; adjust if your API expects additional data.
      body: jsonEncode({}),
    );

    log("Category Detail API response status: ${url}");
    log("Category Detail API response status: ${response.statusCode}");
    log("Category Detail API response: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AppCategoryDetailResponse.fromJson(data);
    } else {
      throw Exception("Failed to load services: ${response.statusCode}");
    }
  }
}
