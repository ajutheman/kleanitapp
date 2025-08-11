import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/pref_resources.dart';
import '../modle/category_model.dart';

// // import 'main_category_model.dart';
//
// class CategoryRepository {
//   final String baseUrl =
//       "https://kleanit.planetprouae.com/api/customer/categorys/list-main-categories";
//
//   Future<List<MainCategory>> fetchCategories(String token) async {
//     final url = Uri.parse(baseUrl);
//     final response = await http.post(
//       "$url?type=${type}",
//       headers: {
//         "Authorization": "Bearer $token",
//         "Content-Type": "application/json",
//         "Accept": "application/json",
//       },
//       body: jsonEncode({}), // sending an empty JSON body
//     );
//     log("Category API response status: ${response.statusCode}");
//     log("Category API response: ${response.body}");
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data["success"] == true && data["data"] != null) {
//         List categoriesJson = data["data"];
//         return categoriesJson
//             .map<MainCategory>((json) => MainCategory.fromJson(json))
//             .toList();
//       } else {
//         throw Exception("Failed to fetch categories: ${data['message']}");
//       }
//     } else {
//       throw Exception("Failed to fetch categories: ${response.statusCode}");
//     }
//   }
// }
class CategoryRepository {
  final String baseUrl = "https://backend.kleanit.ae/api/customer/categorys/list-main-categories";

  Future<List<MainCategory>> fetchCategories(String type) async {
    // final url = Uri.parse("$baseUrl?type=$type");  // 👈 appending type in URL
    final url = Uri.parse("$baseUrl?type=$type");
    log(" Category API url:$url");
    final token = await _getToken();
    final response = await http.post(
      // 👈 use GET because you are just fetching
      url,
      headers: {"Authorization": "Bearer $token", "Content-Type": "application/json", "Accept": "application/json"},
    );
    log("url:$url");
    log("Category API response status: ${response.statusCode}");
    log(" Category API url:$url");
    log("Category API response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["success"] == true && data["data"] != null) {
        List categoriesJson = data["data"];
        return categoriesJson.map<MainCategory>((json) => MainCategory.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch categories: ${data['message']}");
      }
    } else {
      throw Exception("Failed to fetch categories: ${response.statusCode}");
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefResources.USER_ACCESS_TOCKEN) ?? "";
  }
}
