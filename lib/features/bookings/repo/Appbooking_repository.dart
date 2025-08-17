//
// import 'dart:convert';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:kleanitapp/core/constants/Spydo_pref_resources.dart';
// import 'package:kleanitapp/core/utils/auth_helper.dart'; // 👈 added
// import 'package:kleanitapp/core/utils/url_resources.dart';
// import 'package:kleanitapp/features/bookings/model/Appweekly_schedule.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../model/Appbook_detail.dart';
// import '../model/Appbooking.dart';
//
// class AppBookingRepository {
//   final dio = Dio();
//
//   Future<String?> _getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(AppPrefResources.USER_ACCESS_TOCKEN);
//   }
//
//   Future<Map<String, dynamic>> fetchBookings({int page = 1, String status = "All"}) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) {
//         await handleUnauthorized();
//         throw Exception("Unauthorized");
//       }
//
//       final url = "${AppUrlResources.AppbookingList}?page=$page&status=$status";
//       debugPrint("📥 [GET $url] ");
//       final response = await dio.get(url, options: Options(headers: {"Authorization": "Bearer $token"}));
//
//       if (response.statusCode == 200) {
//         final data = response.data;
//         final List<AppBookingModel> bookings = (data['orders'] as List).map((e) => AppBookingModel.fromJson(e)).toList();
//         return {'bookings': bookings, 'currentPage': data['pagination']['current_page'], 'totalPages': data['pagination']['last_page']};
//       } else if (response.statusCode == 401) {
//         await handleUnauthorized();
//         throw Exception("Session expired");
//       } else {
//         throw Exception("Failed to load bookings");
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 401) await handleUnauthorized();
//       throw Exception(e.response?.data?['message'] ?? "Error fetching bookings");
//     }
//   }
//
//   Future<AppBookingDetails> getOrderDetails(String orderId) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) {
//         await handleUnauthorized();
//         throw Exception("Unauthorized");
//       }
//
//       final url = "${AppUrlResources.ApporderDetails}/$orderId";
//       final response = await dio.get(url, options: Options(headers: {"Authorization": "Bearer $token"}));
//
//       if (response.statusCode == 200) {
//         return AppBookingDetails.fromJson(response.data['order']);
//       } else if (response.statusCode == 401) {
//         await handleUnauthorized();
//         throw Exception("Session expired");
//       } else {
//         throw Exception("Failed to fetch order details");
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 401) await handleUnauthorized();
//       throw Exception("Error fetching order details: ${e.response?.data?['message'] ?? e.toString()}");
//     }
//   }
//
//   Future<List<AppWeeklySchedule>> fetchScheduleDays(String orderId) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) {
//         await handleUnauthorized();
//         throw Exception("Unauthorized");
//       }
//
//       final url = "${AppUrlResources.AppscheduleDays}/$orderId";
//       final response = await dio.get(url, options: Options(headers: {"Authorization": "Bearer $token"}));
//       // URL + status + body
//       print("⬅️ ${response.statusCode} ${response.statusMessage} • ${response.realUri}");
//       try {
//         print("Response body:\n${(response.data)}");
//       } catch (_) {
//         print("Response body (raw): ${response.data}");
//       }
//       print("Response headers: ${response.headers}");
//
//       if (response.statusCode == 200) {
//         final data = response.data['weekly_schedules'] as List;
//         return data.map((e) => AppWeeklySchedule.fromJson(e)).toList();
//       } else if (response.statusCode == 401) {
//         await handleUnauthorized();
//         throw Exception("Session expired");
//       } else {
//         throw Exception("Failed to fetch schedule days");
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 401) await handleUnauthorized();
//       throw Exception("Error fetching schedule days: ${e.response?.data?['message'] ?? e.toString()}");
//     }
//   }
//
//   Future<void> updateSchedule(int id, WeeklyScheduleDays days) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) {
//         await handleUnauthorized();
//         throw Exception("Unauthorized");
//       }
//
//       final url = "${AppUrlResources.AppscheduleUpdate}/$id";
//       final body = {
//         "days": [
//           {"day": "sunday", "enabled": days.sunday ? "yes" : "no"},
//           {"day": "monday", "enabled": days.monday ? "yes" : "no"},
//           {"day": "tuesday", "enabled": days.tuesday ? "yes" : "no"},
//           {"day": "wednesday", "enabled": days.wednesday ? "yes" : "no"},
//           {"day": "thursday", "enabled": days.thursday ? "yes" : "no"},
//           {"day": "friday", "enabled": days.friday ? "yes" : "no"},
//           {"day": "saturday", "enabled": days.saturday ? "yes" : "no"},
//         ],
//       };
//
//       final response = await dio.put(url, data: jsonEncode(body), options: Options(headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"}));
//
//       if (response.statusCode == 401) {
//         await handleUnauthorized();
//         throw Exception("Session expired");
//       }
//
//       if (response.statusCode != 200) {
//         throw Exception("Failed to update schedule");
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 401) await handleUnauthorized();
//       throw Exception("Update schedule failed: ${e.response?.data?['message'] ?? e.toString()}");
//     }
//   }
//
//   Future<void> cancelOrder(String orderId, String reason) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) {
//         await handleUnauthorized();
//         throw Exception("Unauthorized");
//       }
//
//       final url = "${AppUrlResources.AppcancelOrder}/$orderId";
//       final body = {"cancellation_reason": reason};
//
//       final response = await dio.post(url, data: jsonEncode(body), options: Options(headers: {"Authorization": "Bearer $token"}));
//
//       if (response.statusCode == 401) {
//         await handleUnauthorized();
//         throw Exception("Session expired");
//       }
//
//       if (response.statusCode != 200) {
//         throw Exception("Failed to cancel order");
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 401) await handleUnauthorized();
//       throw Exception(e.response?.data?['message'] ?? e.response?.data?['error'] ?? "Failed to cancel order");
//     }
//   }
//
//   Future<void> downloadInvoice(String encryptedInvoiceId) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) {
//         await handleUnauthorized();
//         throw Exception("Unauthorized");
//       }
//
//       final url = "https://backend.kleanit.ae/api/customer/orders/invoice/$encryptedInvoiceId";
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = "${directory.path}/invoice_$encryptedInvoiceId.pdf";
//
//       final response = await dio.download(url, filePath, options: Options(headers: {"Authorization": "Bearer $token", "Accept": "application/pdf"}));
//
//       if (response.statusCode == 401) {
//         await handleUnauthorized();
//         throw Exception("Session expired");
//       }
//
//       if (response.statusCode == 200) {
//         OpenFile.open(filePath);
//       } else {
//         throw Exception("Failed to download invoice");
//       }
//     } catch (e) {
//       throw Exception("Error downloading invoice: $e");
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kleanitapp/core/constants/Spydo_pref_resources.dart';
import 'package:kleanitapp/core/utils/auth_helper.dart';
import 'package:kleanitapp/core/utils/url_resources.dart';
import 'package:kleanitapp/features/bookings/model/Appweekly_schedule.dart';
import 'package:kleanitapp/features/bookings/model/TimeSlotOption.dart' show TimeSlotOption;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../../model/time_slot_option.dart';

import '../model/Appbook_detail.dart';
import '../model/Appbooking.dart'; // contains OrdersResponse, AppBookingModel, etc.

class AppBookingRepository {
  AppBookingRepository()
      : dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      // Accept JSON by default
      headers: const {"Accept": "application/json"},
      // Only throw DioException for 5xx; we’ll handle 4xx explicitly
      validateStatus: (s) => s != null && s < 500,
    ),
  );

  final Dio dio;

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppPrefResources.USER_ACCESS_TOCKEN);
  }

  Map<String, String> _authHeaders(String token, {bool json = false}) => {
    "Authorization": "Bearer $token",
    if (json) "Content-Type": "application/json",
  };

  /// GET /bookings
  /// Returns: {'bookings': List<AppBookingModel>, 'currentPage': int, 'totalPages': int}
  Future<Map<String, dynamic>> fetchBookings({int page = 1, String status = "All"}) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = AppUrlResources.AppbookingList;
      if (kDebugMode) debugPrint("📥 [GET] $url ? page=$page&status=$status");

      final response = await dio.get(
        url,
        queryParameters: {"page": page, "status": status},
        options: Options(headers: _authHeaders(token)),
      );

      if (kDebugMode) {
        debugPrint("⬅️ ${response.statusCode} ${response.statusMessage} • ${response.realUri}");
      }

      if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      }
      if (response.statusCode != 200 || response.data == null) {
        throw Exception("Failed to load bookings");
      }

      // Parse with the new top-level response
      final ordersResponse = OrdersResponse.fromJson(Map<String, dynamic>.from(response.data as Map));
      return {
        'bookings': ordersResponse.orders,
        'currentPage': ordersResponse.pagination.currentPage,
        'totalPages': ordersResponse.pagination.lastPage,
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await handleUnauthorized();
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'] ?? "Error fetching bookings")
          : "Error fetching bookings";
      throw Exception(msg);
    }
  }

  /// GET /orders/{id}
  Future<AppBookingDetails> getOrderDetails(String orderId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "${AppUrlResources.ApporderDetails}/$orderId";
      if (kDebugMode) debugPrint("📥 [GET] $url");

      final response = await dio.get(url, options: Options(headers: _authHeaders(token)));

      if (kDebugMode) {
        debugPrint("⬅️ ${response.statusCode} ${response.statusMessage} • ${response.realUri}");
      }

      if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      }
      if (response.statusCode != 200 || response.data == null) {
        throw Exception("Failed to fetch order details");
      }

      final map = Map<String, dynamic>.from(response.data as Map);
      return AppBookingDetails.fromJson(Map<String, dynamic>.from(map['order'] as Map));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await handleUnauthorized();
      throw Exception("Error fetching order details: ${e.response?.data?['message'] ?? e.toString()}");
    }
  }

  /// GET /orders/{id}/schedule-days
  Future<List<AppWeeklySchedule>> fetchScheduleDays(String orderId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "${AppUrlResources.AppscheduleDays}/$orderId";
      if (kDebugMode) debugPrint("📥 [GET] $url");

      final response = await dio.get(url, options: Options(headers: _authHeaders(token)));

      if (kDebugMode) {
        debugPrint("⬅️ ${response.statusCode} ${response.statusMessage} • ${response.realUri}");
        try {
          debugPrint("Response body:\n${response.data}");
        } catch (_) {
          debugPrint("Response body (raw): ${response.data}");
        }
        debugPrint("Response headers: ${response.headers}");
      }

      if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      }
      if (response.statusCode != 200 || response.data == null) {
        throw Exception("Failed to fetch schedule days");
      }

      final list = (Map<String, dynamic>.from(response.data as Map)['weekly_schedules'] as List?) ?? const [];
      return list.map((e) => AppWeeklySchedule.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await handleUnauthorized();
      throw Exception("Error fetching schedule days: ${e.response?.data?['message'] ?? e.toString()}");
    }
  }

  /// PUT /weekly-schedules/{id}
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

      if (kDebugMode) {
        debugPrint("📝 [PUT] $url");
        debugPrint("Body: ${jsonEncode(body)}");
      }

      final response = await dio.put(
        url,
        data: jsonEncode(body),
        options: Options(headers: _authHeaders(token, json: true)),
      );

      if (kDebugMode) {
        debugPrint("⬅️ ${response.statusCode} ${response.statusMessage}");
      }

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

  /// POST /orders/{id}/cancel
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "${AppUrlResources.AppcancelOrder}/$orderId";
      final body = {"cancellation_reason": reason};

      if (kDebugMode) {
        debugPrint("🟥 [POST] $url");
        debugPrint("Body: ${jsonEncode(body)}");
      }

      final response = await dio.post(
        url,
        data: jsonEncode(body),
        options: Options(headers: _authHeaders(token, json: true)),
      );

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

  /// GET (download) /orders/invoice/{encryptedId}
  Future<void> downloadInvoice(String encryptedInvoiceId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "https://backend.kleanit.ae/api/customer/orders/invoice/$encryptedInvoiceId";
      final dir = await getApplicationDocumentsDirectory();
      final safeId = encryptedInvoiceId.replaceAll(RegExp(r'[^a-zA-Z0-9-_]'), '_');
      final path = "${dir.path}/invoice_$safeId.pdf";

      if (kDebugMode) debugPrint("⬇️ [GET] $url → $path");

      // Stream the PDF
      final response = await dio.get<ResponseBody>(
        url,
        options: Options(
          headers: _authHeaders(token),
          responseType: ResponseType.stream,
          followRedirects: true,
        ),
      );

      if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      }
      if (response.statusCode != 200 || response.data == null) {
        throw Exception("Failed to download invoice");
      }

      // inside downloadInvoice(...)
      final file = File(path);
      final sink = file.openWrite();                       // IOSink == StreamConsumer<List<int>>
      await response.data!.stream.cast<List<int>>().pipe(sink);
      await sink.close();
      await OpenFile.open(path);

    } catch (e) {
      throw Exception("Error downloading invoice: $e");
    }
  }

// add this import

// inside class AppBookingRepository { ... add:
  Future<List<TimeSlotOption>> fetchTimeSlotsForDate(DateTime date) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      // API example shows day without leading zero (e.g. 2025-07-2)
      final y = date.year;
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString(); // no pad
      final ymd = "$y-$m-$d";

      final url = "https://backend.kleanit.ae/api/customer/cart/list-time-schedules";
      final response = await dio.get(
        url,
        queryParameters: {"date": ymd},
        options: Options(headers: _authHeaders(token)),
      );

      if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      }
      if (response.statusCode != 200 || response.data == null) {
        throw Exception("Failed to load time slots");
      }

      final map = Map<String, dynamic>.from(response.data as Map);
      final list = (map['time_schedules'] as List?) ?? const [];
      return list.map((e) => TimeSlotOption.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await handleUnauthorized();
      throw Exception(e.response?.data?['message'] ?? "Error fetching time slots");
    }
  }

}
