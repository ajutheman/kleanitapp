import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:kleanitapp/core/constants/url_resources.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/pref_resources.dart';
import '../modle/review_model.dart';

class ReviewRepository {
  final dio = Dio();

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
  }

  // ✅ Fetch Reviews
  Future<ReviewResponse> fetchReviews({required int id}) async {
    final url = "${UrlResources.reviewList}/$id";

    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Unauthorized: Access token not found");
      }

      print("=== Fetch Reviews Request ===");
      print("URL: $url");
      final response = await dio.get(
        "${UrlResources.reviewList}/$id",
        options: Options(headers: {"Content-Type": "application/json", "Authorization": "Bearer $token", "Accept": "application/json"}),
      );

      // ✅ Print the entire raw response data
      print("=== Fetch Reviews Response ===");
      print("Status Code: ${response.statusCode}");
      print(jsonEncode(response.data));
      print("==============================");

      if (response.statusCode == 200) {
        return ReviewResponse.fromJson(response.data);
      } else {
        throw Exception("Failed to fetch reviews: ${response.data}");
      }
    } on DioException catch (e) {
      print("DioException: ${e.response?.data}");
      print("=== Fetch Reviews DioException ===");
      print("URL: $url");
      print("Error Response: ${jsonEncode(e.response?.data)}");
      throw Exception(e.response?.data?['message'] ?? "Failed to fetch reviews");
    } catch (e) {
      print("=== Fetch Reviews General Error ===");
      print(e.toString());
      throw Exception("Error fetching reviews: $e");
    }
  } // ✅ Fetch Reviews

  Future<bool> submitReview({required int id, required String review, required int rating}) async {
    final url = "${UrlResources.reviewUpdate}/$id";
    final payload = {'review': review, 'rating': rating};

    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Unauthorized: Access token not found");
      }
      print("=== Submit Review Request ===");
      print("URL: $url");
      print("Payload: ${jsonEncode(payload)}");

      final response = await dio.post(
        "${UrlResources.reviewUpdate}/$id",
        data: jsonEncode({'review': review, 'rating': rating}),
        options: Options(headers: {"Content-Type": "application/json", "Authorization": "Bearer $token", "Accept": "application/json"}),
      );

      // ✅ Print the entire raw response data
      print("=== Submit Review Response ===");
      print("Status Code: ${response.statusCode}");
      print(jsonEncode(response.data));
      print("==============================");

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Failed to add reviews: ${response.data}");
      }
    } on DioException catch (e) {
      print("=== Submit Review DioException ===");
      print("URL: $url");
      print("Payload: ${jsonEncode(payload)}");
      print("Error Response: ${jsonEncode(e.response?.data)}");
      throw Exception(e.response?.data?['message'] ?? e.response?.data?['error'] ?? "Failed to add reviews");
    } catch (e) {
      print("=== Submit Review General Error ===");
      print(e.toString());

      throw Exception("Error add reviews: $e");
    }
  }
}
