// import 'dart:convert';
//
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../core/constants/pref_resources.dart';
// import '../../../core/constants/url_resources.dart';
// import '../model/order_calculation.dart';
// import '../model/order_response.dart';
// import '../model/time_schedule.dart';
//
// class OrderRepository {
//   final dio = Dio();
//
//   Future<String?> _getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
//   }
//   void logApiCall(String method, String url, {dynamic body}) {
//     print("➡️ [$method] $url");
//     if (body != null) print("📦 Body: ${jsonEncode(body)}");
//     print("🌐 Base URL: ${dio.options.baseUrl}");
//   }
//   Future<OrderCalculation> calculateOrder(List<String> cartIds, String coupon) async {
//     print("Dio Base URL: ${dio.options.baseUrl}");
//     print("POST ${UrlResources.calculateOrder}");
//     print("Request body: ${jsonEncode({"cart_ids": cartIds, 'coupon_code': coupon})}");
//
//     final token = await _getAccessToken();
//     if (token == null) {
//       throw Exception("Unauthorized: Access token not found");
//     }
//
//     final response = await dio.post(
//       UrlResources.calculateOrder,
//       data: jsonEncode({"cart_ids": cartIds, 'coupon_code': coupon}),
//       options: Options(
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       ),
//     );
//     if (response.statusCode == 200) {
//       return OrderCalculation.fromJson(response.data);
//     } else {
//       throw Exception("Failed to calculate order: ${response.data}");
//     }
//   }
//
//   Future<OrderResponse> placeOrder({
//     required List<String> cartIds,
//     required String addressId,
//     required String scheduleTime,
//     required int? subscriptionFeq,
//     required String notes,
//     required String paymentMethod,
//     required int bedrooms,
//     required bool petsPresent,
//     required int beds,
//     required int sofaBeds,
//     required bool withLinen,
//     required bool withSupplies,
//     required String checkInTime,
//     required String checkOutTime,
//     required int occupancy,
//     required String doorAccessCode,
//     required String coupon,
//     required String date,
//     required String typeOfCleaning,
//     required String nextGuestCheckInTime,
//     required String wifiAccessCode,
//   }) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) throw Exception("Unauthorized: Access token not found");
//
// print("object");
// print("response date : ${date}");
// print("response date : ${UrlResources.saveOrder}");
//
//       final response = await dio.post(
//         UrlResources.saveOrder,
//         data: jsonEncode({
//           "cart_ids": cartIds,
//           "customer_address_id": addressId,
//           "scheduled_time_id": scheduleTime,
//           "notes": notes,
//           "payment_method": paymentMethod,
//           "has_subscription": subscriptionFeq != null,
//           "subscription_duration": subscriptionFeq ?? 1,
//           "bedrooms": bedrooms,
//
//           "pets_present": petsPresent,
//           "beds": beds,
//           "sofa_beds": sofaBeds,
//           "with_linen": withLinen,
//           "with_supplies": withSupplies,
//           "check_in_time": checkInTime,
//           "check_out_time": checkOutTime,
//           "occupancy": occupancy,
//           "door_access_code": doorAccessCode,
//           "booking_date": date,
//           'coupon_code': coupon,
//           "wifi_access_code": wifiAccessCode,
//           "next_guest_check_in_time": nextGuestCheckInTime,
//           "type_of_cleaning": typeOfCleaning,
//         }),
//         options: Options(
//           headers: {
//             "Content-Type": "application/json",
//             "Authorization": "Bearer $token",
//           },
//         ),
//       );
// // print("object${response.}");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return OrderResponse.fromJson(response.data);
//       } else {
//         throw Exception("Failed to place order: ${response.data}");
//       }
//     } on DioException catch (e) {
//       print(e.response?.data);
//       throw e.response?.data['error'] ?? e.response?.data['message'] ?? "Failed to order";
//     }
//   }
//
//   Future<List<TimeSchedule>> fetchSchedules({required String date}) async {
//     final token = await _getAccessToken();
//     if (token == null) throw Exception("Unauthorized: Access token not found");
//
//     final response = await dio.get(
//       UrlResources.getScheduleList, // You’ll need to define this constant
//       queryParameters: {'date':date},
//       options: Options(
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//       ),
//     );  print("time_schedules'");
//     print("dio.options.baseUrl:${dio.options.baseUrl}");
//     print("time_schedules'");
//     print("time_schedules:${response}");
//     if (response.statusCode == 200) {
//       print("time_schedules'");
//       print("time_schedules:${response}'");
//       final List data = response.data['time_schedules'];
//       print("time_schedules'");
//       print("time_schedules:${response}'");
//
//       return data.map((e) => TimeSchedule.fromJson(e)).toList();
//     } else {
//       throw Exception("Failed to load schedules");
//     }
//   }
//   Future<bool> validateCoupon(String couponCode) async {
//     final token = await _getAccessToken();
//     if (token == null) throw Exception("Unauthorized: Access token not found");
//
//     final response = await dio.post(
//       UrlResources.validateCoupon, // Define this URL in UrlResources
//       data: jsonEncode({
//         "coupon_code": couponCode,
//       }),
//       options: Options(
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       ),
//     );
//
//     if (response.statusCode == 200) {
//       return true;
//     } else {
//       throw Exception(response.data['message'] ?? "Invalid coupon");
//     }
//   }
// }
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/pref_resources.dart';
import '../../../core/constants/url_resources.dart';
import '../model/order_calculation.dart';
import '../model/order_response.dart';
import '../model/time_schedule.dart';

class OrderRepository {
  final dio = Dio();

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
  }

  void logApiCall(String method, String url, {dynamic body}) {
    print("➡️ [$method] $url");
    if (body != null) print("📦 Body: ${jsonEncode(body)}");
    print("🌐 Base URL: ${dio.options.baseUrl}");
  }

  Future<OrderCalculation> calculateOrder(List<String> cartIds, String coupon,
      {int? subscriptionFrequency}) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception("Unauthorized: Access token not found");

    final payload = {
      "cart_ids": cartIds,
      "coupon": coupon,
      if (subscriptionFrequency != null)
        "subscription_frequency": subscriptionFrequency,
    };
    // final body = {"cart_ids": cartIds, 'coupon_code': coupon};
    print("--------------------------");
    logApiCall("POST", UrlResources.calculateOrder, body: payload);
    print("--------------------------");
    final response = await dio.post(
      UrlResources.calculateOrder,
      data: jsonEncode(payload),
      // data: jsonEncode(body),
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
    );
    print("--------------------------");
    print("🌐 Base URL 1: ${dio.options.baseUrl}");
    print("--------------------------");
    // print("🌐 Base response: ${response}");
    print("--------------------------");
    print("🌐 response data: ${response.data}");
    print("🌐 statusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      return OrderCalculation.fromJson(response.data);
    } else {
      throw Exception("Failed to calculate order: ${response.data}");
    }
  }

  Future<OrderResponse> placeOrder({
    required List<String> cartIds,
    required String addressId,
    required String scheduleTime,
    required int? subscriptionFeq,
    required String notes,
    required String paymentMethod,
    required int bedrooms,
    required bool petsPresent,
    required int beds,
    required int sofaBeds,
    required bool withLinen,
    required bool withSupplies,
    required String checkInTime,
    required String checkOutTime,
    required int occupancy,
    required String doorAccessCode,
    required String coupon,
    required String date,
    required String typeOfCleaning,
    required String nextGuestCheckInTime,
    required String wifiAccessCode,
  }) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception("Unauthorized: Access token not found");

    final body = {
      "cart_ids": cartIds,
      "customer_address_id": addressId,
      "scheduled_time_id": scheduleTime,
      "notes": notes,
      "payment_method": paymentMethod,
      "has_subscription": subscriptionFeq != null,
      "subscription_duration": subscriptionFeq ?? 1,
      "bedrooms": bedrooms,
      "pets_present": petsPresent,
      "beds": beds,
      "sofa_beds": sofaBeds,
      "with_linen": withLinen,
      "with_supplies": withSupplies,
      "check_in_time": checkInTime,
      "check_out_time": checkOutTime,
      "occupancy": occupancy,
      "door_access_code": doorAccessCode,
      "booking_date": date,
      'coupon_code': coupon,
      "wifi_access_code": wifiAccessCode,
      "next_guest_check_in_time": nextGuestCheckInTime,
      "type_of_cleaning": typeOfCleaning,
    };

    logApiCall("POST", UrlResources.saveOrder, body: body);

    try {
      final response = await dio.post(
        UrlResources.saveOrder,
        // data: jsonEncode(body),
        data: body,

        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OrderResponse.fromJson(response.data);
      } else {
        throw Exception("Failed to place order: ${response.data}");
      }
    } on DioException catch (e) {
      print("❌ Error: ${e.response?.data}");
      throw e.response?.data['error'] ??
          e.response?.data['message'] ??
          "Failed to place order";
    }
  }

  Future<List<TimeSchedule>> fetchSchedules({required String date}) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception("Unauthorized: Access token not found");

    logApiCall("GET", UrlResources.getScheduleList + "?date=$date");

    final response = await dio.get(
      UrlResources.getScheduleList,
      queryParameters: {'date': date},
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ),
    );
    print("🌐 response data: ${response.data}");
    if (response.statusCode == 200) {
      final List data = response.data['time_schedules'];
      return data.map((e) => TimeSchedule.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load schedules");
    }
  }

  Future<bool> validateCoupon(String couponCode) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception("Unauthorized: Access token not found");

    final body = {"coupon_code": couponCode};
    logApiCall("POST", UrlResources.validateCoupon, body: body);

    final response = await dio.post(
      UrlResources.validateCoupon,
      data: jsonEncode(body),
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? "Invalid coupon");
    }
  }
}
