
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kleanitapp/core/constants/Spydo_pref_resources.dart';
import 'package:kleanitapp/core/utils/auth_helper.dart'; // 👈 added
import 'package:kleanitapp/core/utils/url_resources.dart';
import 'package:kleanitapp/features/bookings/model/Appweekly_schedule.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/Appbook_detail.dart';
import '../model/Appbooking.dart';

class AppBookingRepository {
  final dio = Dio();

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppPrefResources.USER_ACCESS_TOCKEN);
  }

  Future<Map<String, dynamic>> fetchBookings({int page = 1, String status = "All"}) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "${AppUrlResources.AppbookingList}?page=$page&status=$status";
      debugPrint("📥 [GET $url] ");
      final response = await dio.get(url, options: Options(headers: {"Authorization": "Bearer $token"}));

      if (response.statusCode == 200) {
        final data = response.data;
        final List<AppBookingModel> bookings = (data['orders'] as List).map((e) => AppBookingModel.fromJson(e)).toList();
        return {'bookings': bookings, 'currentPage': data['pagination']['current_page'], 'totalPages': data['pagination']['last_page']};
      } else if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      } else {
        throw Exception("Failed to load bookings");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await handleUnauthorized();
      throw Exception(e.response?.data?['message'] ?? "Error fetching bookings");
    }
  }

  Future<AppBookingDetails> getOrderDetails(String orderId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "${AppUrlResources.ApporderDetails}/$orderId";
      final response = await dio.get(url, options: Options(headers: {"Authorization": "Bearer $token"}));

      if (response.statusCode == 200) {
        return AppBookingDetails.fromJson(response.data['order']);
      } else if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      } else {
        throw Exception("Failed to fetch order details");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await handleUnauthorized();
      throw Exception("Error fetching order details: ${e.response?.data?['message'] ?? e.toString()}");
    }
  }

  Future<List<AppWeeklySchedule>> fetchScheduleDays(String orderId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "${AppUrlResources.AppscheduleDays}/$orderId";
      final response = await dio.get(url, options: Options(headers: {"Authorization": "Bearer $token"}));
      // URL + status + body
      print("⬅️ ${response.statusCode} ${response.statusMessage} • ${response.realUri}");
      try {
        print("Response body:\n${(response.data)}");
      } catch (_) {
        print("Response body (raw): ${response.data}");
      }
      print("Response headers: ${response.headers}");

      if (response.statusCode == 200) {
        final data = response.data['weekly_schedules'] as List;
        return data.map((e) => AppWeeklySchedule.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      } else {
        throw Exception("Failed to fetch schedule days");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await handleUnauthorized();
      throw Exception("Error fetching schedule days: ${e.response?.data?['message'] ?? e.toString()}");
    }
  }

  Future<void> updateSchedule(int id, WeeklyScheduleDays days) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "${AppUrlResources.AppscheduleUpdate}/$id";
      final body = {
        "days": [
          {"day": "sunday", "enabled": days.sunday ? "yes" : "no"},
          {"day": "monday", "enabled": days.monday ? "yes" : "no"},
          {"day": "tuesday", "enabled": days.tuesday ? "yes" : "no"},
          {"day": "wednesday", "enabled": days.wednesday ? "yes" : "no"},
          {"day": "thursday", "enabled": days.thursday ? "yes" : "no"},
          {"day": "friday", "enabled": days.friday ? "yes" : "no"},
          {"day": "saturday", "enabled": days.saturday ? "yes" : "no"},
        ],
      };

      final response = await dio.put(url, data: jsonEncode(body), options: Options(headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"}));

      if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      }

      if (response.statusCode != 200) {
        throw Exception("Failed to update schedule");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await handleUnauthorized();
      throw Exception("Update schedule failed: ${e.response?.data?['message'] ?? e.toString()}");
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "${AppUrlResources.AppcancelOrder}/$orderId";
      final body = {"cancellation_reason": reason};

      final response = await dio.post(url, data: jsonEncode(body), options: Options(headers: {"Authorization": "Bearer $token"}));

      if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      }

      if (response.statusCode != 200) {
        throw Exception("Failed to cancel order");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await handleUnauthorized();
      throw Exception(e.response?.data?['message'] ?? e.response?.data?['error'] ?? "Failed to cancel order");
    }
  }

  Future<void> downloadInvoice(String encryptedInvoiceId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "https://backend.kleanit.ae/api/customer/orders/invoice/$encryptedInvoiceId";
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/invoice_$encryptedInvoiceId.pdf";

      final response = await dio.download(url, filePath, options: Options(headers: {"Authorization": "Bearer $token", "Accept": "application/pdf"}));

      if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      }

      if (response.statusCode == 200) {
        OpenFile.open(filePath);
      } else {
        throw Exception("Failed to download invoice");
      }
    } catch (e) {
      throw Exception("Error downloading invoice: $e");
    }
  }
}
