import 'package:dio/dio.dart';
import 'package:kleanitapp/features/home/repo/Appexceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/Spydo_pref_resources.dart';
import '../../../core/constants/Sypdo_url_resources.dart';
import '../modle/Appfaq_item.dart';

class AppFAQRepository {
  final dio = Dio();

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppPrefResources.USER_ACCESS_TOCKEN);
  }

  Future<List<AppFAQItem>> fetchFAQs() async {
    final token = await _getAccessToken();
    if (token == null) {
      throw AppUnauthorizedException("Access token not found. Please log in.");
    }

    try {
      final response = await dio.get(UrlResources.faqList, options: Options(headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"}));

      if (response.statusCode == 200) {
        final decoded = response.data;
        final List<dynamic> data = decoded['data'];
        return data.map((e) => AppFAQItem.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw AppUnauthorizedException("Session expired. Please log in again.");
      } else if (response.statusCode == 400) {
        throw AppBadRequestException("Invalid FAQ request.");
      } else {
        throw Exception("Failed to fetch FAQs");
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = e.response?.data?['message'];

      if (status == 401) {
        throw AppUnauthorizedException(message ?? "Unauthorized access.");
      } else if (status == 400) {
        throw AppBadRequestException(message ?? "Bad request.");
      } else {
        throw Exception(message ?? "Unexpected error while fetching FAQs");
      }
    } catch (e) {
      throw Exception("Unexpected error: ${e.toString()}");
    }
  }
}
