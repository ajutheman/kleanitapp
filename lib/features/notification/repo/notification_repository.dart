import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/notification_model.dart';
import '../../../core/constants/pref_resources.dart';
import '../../../core/constants/url_resources.dart';

class NotificationRepository {
  final dio = Dio();

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    final token = await _getAccessToken();
    if (token == null) throw Exception("Unauthorized");
    final url = UrlResources.notificationList;
    print("🔗 API URL: $url");
    final response = await dio.get(
      UrlResources.notificationList,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      ),
    );
    print("Notification API response: ${response.data}");
    if (response.statusCode == 200) {
      return NotificationModel.listFromJson(response.data['notifications']);
    } else {
      throw Exception("Failed to fetch notifications");
    }
  }
}
