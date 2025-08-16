import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/Spydo_pref_resources.dart';
import '../../../core/constants/Sypdo_url_resources.dart';
import '../model/Appnotification_model.dart';

class AppNotificationRepository {
  final dio = Dio();

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppPrefResources.USER_ACCESS_TOCKEN);
  }

  Future<List<AppNotificationModel>> fetchNotifications() async {
    final token = await _getAccessToken();
    if (token == null) throw Exception("Unauthorized");
    final url = UrlResources.notificationList;
    print("🔗 API URL: $url");
    final response = await dio.get(UrlResources.notificationList, options: Options(headers: {"Authorization": "Bearer $token", "Accept": "application/json"}));
    print("Notification API response: ${response.data}");
    if (response.statusCode == 200) {
      return AppNotificationModel.listFromJson(response.data['notifications']);
    } else {
      throw Exception("Failed to fetch notifications");
    }
  }
}
