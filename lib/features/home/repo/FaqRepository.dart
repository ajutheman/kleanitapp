import 'package:dio/dio.dart';
import 'package:kleanitapp/features/home/repo/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/pref_resources.dart';
import '../../../core/constants/url_resources.dart';
import '../modle/faq_item.dart';
// import '../model/faq_item.dart';

// class FAQRepository {
//   final dio = Dio();
//
//   Future<String?> _getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
//   }
//
//   Future<List<FAQItem>> fetchFAQs() async {
//     final token = await _getAccessToken();
//     if (token == null) throw Exception("Unauthorized: Access token not found");
//
//     final response = await dio.get(
//       UrlResources.faqList, // define faqList URL in UrlResources
//       options: Options(
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//       ),
//     );
//
//     if (response.statusCode == 200) {
//       final decoded = response.data;
//       final List<dynamic> data = decoded['data'];
//       return data.map((e) => FAQItem.fromJson(e)).toList();
//     } else {
//       throw Exception("Failed to fetch FAQs");
//     }
//   }
// }
class FAQRepository {
  final dio = Dio();

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
  }

  Future<List<FAQItem>> fetchFAQs() async {
    final token = await _getAccessToken();
    if (token == null) {
      throw UnauthorizedException("Access token not found. Please log in.");
    }

    try {
      final response = await dio.get(UrlResources.faqList, options: Options(headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"}));

      if (response.statusCode == 200) {
        final decoded = response.data;
        final List<dynamic> data = decoded['data'];
        return data.map((e) => FAQItem.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException("Session expired. Please log in again.");
      } else if (response.statusCode == 400) {
        throw BadRequestException("Invalid FAQ request.");
      } else {
        throw Exception("Failed to fetch FAQs");
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = e.response?.data?['message'];

      if (status == 401) {
        throw UnauthorizedException(message ?? "Unauthorized access.");
      } else if (status == 400) {
        throw BadRequestException(message ?? "Bad request.");
      } else {
        throw Exception(message ?? "Unexpected error while fetching FAQs");
      }
    } catch (e) {
      throw Exception("Unexpected error: ${e.toString()}");
    }
  }
}
