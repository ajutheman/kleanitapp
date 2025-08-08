// import 'dart:convert';
//
// import 'package:dio/dio.dart';
// import 'package:kleanit/core/constants/pref_resources.dart';
// import 'package:kleanit/core/utils/url_resources.dart';
// import 'package:kleanit/features/bookings/model/weekly_schedule.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../model/book_detail.dart';
// import '../model/booking.dart';
//
// class BookingRepository {
//   final dio = Dio();
//
//   Future<String?> _getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
//   }
//
//   Future<Map<String, dynamic>> fetchBookings({int page = 1, String status = "All"}) async {
//     final token = await _getAccessToken();
//     if (token == null) throw Exception("Unauthorized: Token not found");
//
//     final response = await dio.get(
//       "${UrlResources.bookingList}?page=$page&status=$status",
//       options: Options(headers: {"Authorization": "Bearer $token"}),
//     );
//     print("fetchBookings Response: ${response.data}");
//     if (response.statusCode == 200) {
//       final data = response.data;
//       final List<BookingModel> bookings = (data['orders'] as List).map((e) => BookingModel.fromJson(e)).toList();
//
//       return {
//         'bookings': bookings,
//         'currentPage': data['pagination']['current_page'],
//         'totalPages': data['pagination']['last_page'],
//       };
//     } else {
//       throw Exception("Failed to load bookings");
//     }
//   }
//
//   Future<BookingDetails> getOrderDetails(String orderId) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) throw Exception("Unauthorized: Token not found");
//
//       final response = await dio.get(
//         "${UrlResources.orderDetails}/$orderId",
//         options: Options(headers: {"Authorization": "Bearer $token"}),
//       );
//       print("getOrderDetails Response: ${response.data}");
//       if (response.statusCode == 200) {
//         return BookingDetails.fromJson(response.data['order']);
//       } else {
//         throw Exception("Failed to fetch order details");
//       }
//     } catch (e) {
//       throw Exception("Error fetching order details: $e");
//     }
//   }
//
//   /// Fetches schedule days for a given order
//   Future<List<WeeklySchedule>> fetchScheduleDays(String orderId) async {
//     final token = await _getAccessToken();
//     if (token == null) throw Exception("Unauthorized: Token not found");
//
//     final response = await dio.get(
//       "${UrlResources.scheduleDays}/$orderId",
//       options: Options(headers: {"Authorization": "Bearer $token"}),
//     );
//     print("fetchScheduleDays Response: ${response.data}");
//     if (response.statusCode == 200) {
//       final data = response.data['weekly_schedules'] as List;
//       return data.map((e) => WeeklySchedule.fromJson(e)).toList();
//     } else {
//       throw Exception("Failed to fetch schedule days");
//     }
//   }
//
//   /// Updates schedule days for a given order
//   Future<void> updateSchedule(int id, WeeklyScheduleDays days) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) throw Exception("Unauthorized: Token not found");
//
//       final Map<String, dynamic> body = {
//         "days": [
//           {"day": "sunday", "enabled": days.sunday ? "yes" : "no"},
//           {"day": "monday", "enabled": days.monday ? "yes" : "no"},
//           {"day": "tuesday", "enabled": days.tuesday ? "yes" : "no"},
//           {"day": "wednesday", "enabled": days.wednesday ? "yes" : "no"},
//           {"day": "thursday", "enabled": days.thursday ? "yes" : "no"},
//           {"day": "friday", "enabled": days.friday ? "yes" : "no"},
//           {"day": "saturday", "enabled": days.saturday ? "yes" : "no"},
//         ]
//       };
//
//       final response = await dio.put(
//         "${UrlResources.scheduleUpdate}/$id",
//         data: jsonEncode(body),
//         options: Options(
//           headers: {
//             "Authorization": "Bearer $token",
//             "Content-Type": "application/json",
//           },
//         ),
//       );
//       print("updateSchedule Response: ${response.data}");
//
//       if (response.statusCode != 200) {
//         throw Exception("Failed to update schedule");
//       }
//     } on DioException catch (e) {
//       print(e.response?.data);
//     }
//   }
//
//   Future<void> cancelOrder(String orderId, String reason) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) throw Exception("Unauthorized: Token not found");
//
//       final response = await dio.post(
//         "${UrlResources.cancelOrder}/$orderId",
//         data: jsonEncode({"cancellation_reason": reason}),
//         options: Options(headers: {"Authorization": "Bearer $token"}),
//       );
//       print("cancelOrder Response: ${response.data}");
//       if (response.statusCode != 200) {
//         throw Exception("Failed to cancel order");
//       }
//     } on DioException catch (e) {
//       throw e.response?.data['message'] ?? e.response?.data['error'] ?? "Failed to cancel order";
//     }
//   }
//   /// Downloads the invoice for a given order
//   Future<void> downloadInvoice(String encryptedInvoiceId) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) throw Exception("Unauthorized: Token not found");
//
//       final url = "https://kleanit.planetprouae.com/api/customer/orders/invoice/$encryptedInvoiceId";
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = "${directory.path}/invoice_$encryptedInvoiceId.pdf";
//
//       final response = await dio.download(
//         url,
//         filePath,
//         options: Options(
//           headers: {
//             "Authorization": "Bearer $token",
//             "Accept": "application/pdf",
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         OpenFile.open(filePath);
//         print("Invoice downloaded successfully");
//       } else {
//         print("Failed to download invoice. Status Code: ${response.statusCode}");
//         throw Exception("Failed to download invoice");
//       }
//     } catch (e) {
//       print("Download Error: $e");
//       throw Exception("Error downloading invoice: $e");
//     }
//   }
//
// }
// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:kleanit/core/constants/pref_resources.dart';
// import 'package:kleanit/core/utils/url_resources.dart';
// import 'package:kleanit/features/bookings/model/weekly_schedule.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../core/utils/auth_helper.dart';
// import '../model/book_detail.dart';
// import '../model/booking.dart';
//
// class BookingRepository {
//   final dio = Dio();
//
//   Future<String?> _getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
//   }
//
//   Future<Map<String, dynamic>> fetchBookings({int page = 1, String status = "All"}) async {
//     final token = await _getAccessToken();
//     if (token == null) throw Exception("Unauthorized: Token not found");
//
//     final url = "${UrlResources.bookingList}?page=$page&status=$status";
//     if (kDebugMode) debugPrint("GET $url");
//
//     final response = await dio.get(
//       url,
//       options: Options(headers: {"Authorization": "Bearer $token"}),
//     );
//
//     if (kDebugMode) debugPrint("Response: ${response.data}");
//
//     if (response.statusCode == 200) {
//       final data = response.data;
//       final List<BookingModel> bookings = (data['orders'] as List).map((e) => BookingModel.fromJson(e)).toList();
//       return {
//         'bookings': bookings,
//         'currentPage': data['pagination']['current_page'],
//         'totalPages': data['pagination']['last_page'],
//       };
//     }
//     else if (response.statusCode == 401) {
//       await handleUnauthorized();
//       throw Exception("Session expired");
//     }else {
//       throw Exception("Failed to load bookings");
//     }
//   }
//
//   Future<BookingDetails> getOrderDetails(String orderId) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) throw Exception("Unauthorized: Token not found");
//
//       final url = "${UrlResources.orderDetails}/$orderId";
//       if (kDebugMode) debugPrint("GET $url");
//
//       final response = await dio.get(
//         url,
//         options: Options(headers: {"Authorization": "Bearer $token"}),
//       );
//
//       if (kDebugMode) debugPrint("Response: ${response.data}");
//
//       if (response.statusCode == 200) {
//         return BookingDetails.fromJson(response.data['order']);
//       } else {
//         throw Exception("Failed to fetch order details");
//       }
//     } catch (e) {
//       throw Exception("Error fetching order details: $e");
//     }
//   }
//
//   Future<List<WeeklySchedule>> fetchScheduleDays(String orderId) async {
//     final token = await _getAccessToken();
//     if (token == null) throw Exception("Unauthorized: Token not found");
//
//     final url = "${UrlResources.scheduleDays}/$orderId";
//     if (kDebugMode) debugPrint("GET $url");
//
//     final response = await dio.get(
//       url,
//       options: Options(headers: {"Authorization": "Bearer $token"}),
//     );
//
//     if (kDebugMode) debugPrint("Response: ${response.data}");
//
//     if (response.statusCode == 200) {
//       final data = response.data['weekly_schedules'] as List;
//       return data.map((e) => WeeklySchedule.fromJson(e)).toList();
//     } else {
//       throw Exception("Failed to fetch schedule days");
//     }
//   }
//
//   Future<void> updateSchedule(int id, WeeklyScheduleDays days) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) throw Exception("Unauthorized: Token not found");
//
//       final url = "${UrlResources.scheduleUpdate}/$id";
//       final Map<String, dynamic> body = {
//         "days": [
//           {"day": "sunday", "enabled": days.sunday ? "yes" : "no"},
//           {"day": "monday", "enabled": days.monday ? "yes" : "no"},
//           {"day": "tuesday", "enabled": days.tuesday ? "yes" : "no"},
//           {"day": "wednesday", "enabled": days.wednesday ? "yes" : "no"},
//           {"day": "thursday", "enabled": days.thursday ? "yes" : "no"},
//           {"day": "friday", "enabled": days.friday ? "yes" : "no"},
//           {"day": "saturday", "enabled": days.saturday ? "yes" : "no"},
//         ]
//       };
//
//       if (kDebugMode) {
//         debugPrint("PUT $url");
//         debugPrint("Request Body: ${jsonEncode(body)}");
//       }
//
//       final response = await dio.put(
//         url,
//         data: jsonEncode(body),
//         options: Options(
//           headers: {
//             "Authorization": "Bearer $token",
//             "Content-Type": "application/json",
//           },
//         ),
//       );
//
//       if (kDebugMode) debugPrint("Response: ${response.data}");
//
//       if (response.statusCode != 200) {
//         throw Exception("Failed to update schedule");
//       }
//     } on DioException catch (e) {
//       if (kDebugMode) debugPrint("Error Response: ${e.response?.data}");
//       throw Exception("Update schedule failed");
//     }
//   }
//
//   Future<void> cancelOrder(String orderId, String reason) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) throw Exception("Unauthorized: Token not found");
//
//       final url = "${UrlResources.cancelOrder}/$orderId";
//       final body = {"cancellation_reason": reason};
//
//       if (kDebugMode) {
//         debugPrint("POST $url");
//         debugPrint("Request Body: ${jsonEncode(body)}");
//       }
//
//       final response = await dio.post(
//         url,
//         data: jsonEncode(body),
//         options: Options(headers: {"Authorization": "Bearer $token"}),
//       );
//
//       if (kDebugMode) debugPrint("Response: ${response.data}");
//
//       if (response.statusCode != 200) {
//         throw Exception("Failed to cancel order");
//       }
//     } on DioException catch (e) {
//       throw e.response?.data['message'] ?? e.response?.data['error'] ?? "Failed to cancel order";
//     }
//   }
//
//   Future<void> downloadInvoice(String encryptedInvoiceId) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) throw Exception("Unauthorized: Token not found");
//
//       final url = "https://backend.kleanit.ae/api/customer/orders/invoice/$encryptedInvoiceId";
//       // final url = "https://kleanit.planetprouae.com/api/customer/orders/invoice/$encryptedInvoiceId";
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = "${directory.path}/invoice_$encryptedInvoiceId.pdf";
//
//       if (kDebugMode) debugPrint("DOWNLOAD $url → $filePath");
//
//       final response = await dio.download(
//         url,
//         filePath,
//         options: Options(
//           headers: {
//             "Authorization": "Bearer $token",
//             "Accept": "application/pdf",
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         if (kDebugMode) debugPrint("Invoice downloaded to $filePath");
//         OpenFile.open(filePath);
//       } else {
//         if (kDebugMode) debugPrint("Failed to download invoice. Status: ${response.statusCode}");
//         throw Exception("Failed to download invoice");
//       }
//     } catch (e) {
//       if (kDebugMode) debugPrint("Download Error: $e");
//       throw Exception("Error downloading invoice: $e");
//     }
//   }
// }
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kleanit/core/constants/pref_resources.dart';
import 'package:kleanit/core/utils/url_resources.dart';
import 'package:kleanit/core/utils/auth_helper.dart'; // 👈 added
import 'package:kleanit/features/bookings/model/weekly_schedule.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/book_detail.dart';
import '../model/booking.dart';

class BookingRepository {
  final dio = Dio();

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
  }

  Future<Map<String, dynamic>> fetchBookings(
      {int page = 1, String status = "All"}) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "${UrlResources.bookingList}?page=$page&status=$status";
      debugPrint("📥 [GET $url] ");
      final response = await dio.get(
        url,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<BookingModel> bookings = (data['orders'] as List)
            .map((e) => BookingModel.fromJson(e))
            .toList();
        return {
          'bookings': bookings,
          'currentPage': data['pagination']['current_page'],
          'totalPages': data['pagination']['last_page'],
        };
      } else if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      } else {
        throw Exception("Failed to load bookings");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await handleUnauthorized();
      throw Exception(
          e.response?.data?['message'] ?? "Error fetching bookings");
    }
  }

  Future<BookingDetails> getOrderDetails(String orderId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "${UrlResources.orderDetails}/$orderId";
      final response = await dio.get(
        url,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return BookingDetails.fromJson(response.data['order']);
      } else if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      } else {
        throw Exception("Failed to fetch order details");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await handleUnauthorized();
      throw Exception(
          "Error fetching order details: ${e.response?.data?['message'] ?? e.toString()}");
    }
  }

  Future<List<WeeklySchedule>> fetchScheduleDays(String orderId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "${UrlResources.scheduleDays}/$orderId";
      final response = await dio.get(
        url,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        final data = response.data['weekly_schedules'] as List;
        return data.map((e) => WeeklySchedule.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      } else {
        throw Exception("Failed to fetch schedule days");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await handleUnauthorized();
      throw Exception(
          "Error fetching schedule days: ${e.response?.data?['message'] ?? e.toString()}");
    }
  }

  Future<void> updateSchedule(int id, WeeklyScheduleDays days) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "${UrlResources.scheduleUpdate}/$id";
      final body = {
        "days": [
          {"day": "sunday", "enabled": days.sunday ? "yes" : "no"},
          {"day": "monday", "enabled": days.monday ? "yes" : "no"},
          {"day": "tuesday", "enabled": days.tuesday ? "yes" : "no"},
          {"day": "wednesday", "enabled": days.wednesday ? "yes" : "no"},
          {"day": "thursday", "enabled": days.thursday ? "yes" : "no"},
          {"day": "friday", "enabled": days.friday ? "yes" : "no"},
          {"day": "saturday", "enabled": days.saturday ? "yes" : "no"},
        ]
      };

      final response = await dio.put(
        url,
        data: jsonEncode(body),
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 401) {
        await handleUnauthorized();
        throw Exception("Session expired");
      }

      if (response.statusCode != 200) {
        throw Exception("Failed to update schedule");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await handleUnauthorized();
      throw Exception(
          "Update schedule failed: ${e.response?.data?['message'] ?? e.toString()}");
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url = "${UrlResources.cancelOrder}/$orderId";
      final body = {"cancellation_reason": reason};

      final response = await dio.post(
        url,
        data: jsonEncode(body),
        options: Options(headers: {"Authorization": "Bearer $token"}),
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
      throw Exception(e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          "Failed to cancel order");
    }
  }

  Future<void> downloadInvoice(String encryptedInvoiceId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        await handleUnauthorized();
        throw Exception("Unauthorized");
      }

      final url =
          "https://backend.kleanit.ae/api/customer/orders/invoice/$encryptedInvoiceId";
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/invoice_$encryptedInvoiceId.pdf";

      final response = await dio.download(
        url,
        filePath,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/pdf",
          },
        ),
      );

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
