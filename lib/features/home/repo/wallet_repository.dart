// import 'package:dio/dio.dart';
// import 'package:kleanitapp/core/constants/pref_resources.dart';
// import 'package:kleanitapp/core/constants/url_resources.dart';
// import 'package:kleanitapp/features/home/repo/exceptions.dart' show BadRequestException, UnauthorizedException;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../modle/wallet_details.dart';
// import 'WalletTransaction.dart';
// class WalletRepository {
//   final dio = Dio();
//
//   Future<double> fetchWalletBalance() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString(PrefResources.USER_ACCESS_TOCKEN) ?? '';
//
//       final response = await dio.get(
//         UrlResources.getWalletBalance,
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//           },
//         ),
//       );
//       print("🔵 [Wallet Balance]");
//       print("➡️ URL: $UrlResources");
//       print("➡️ URL: $UrlResources.getWalletBalance");
//       print("➡️ Headers: Authorization: Bearer $token");
//       print("✅ Status Code: ${response.statusCode}");
//       print("🟢 Response Body: ${response.data}");
//       if (response.statusCode == 200) {
//         final data = response.data;
//         double balance = double.tryParse(data['wallet_amount'].toString()) ?? 0;
//         return balance;
//       }
//       else if (response.statusCode == 401) {
//         throw UnauthorizedException("Session expired. Please log in again.");
//       } else if (response.statusCode == 400) {
//         throw BadRequestException("Invalid wallet balance request.");
//       }
//       else {
//         throw Exception('Failed to fetch wallet balance');
//       }
//     } on DioException catch (e) {
//       print("❌ [Wallet Balance] Error Response: ${e.response?.data}");
//       throw Exception(e.response?.data?['message'] ?? "Failed to add to cart");
//     } catch (e) {
//       print("❌ [Wallet Balance] Unknown Error: $e");
//       throw Exception('Error: ${e.toString()}');
//     }
//   }
// // ✅ New function — added safely
//   Future<WalletDetails> fetchWalletDetails() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString(PrefResources.USER_ACCESS_TOCKEN) ?? '';
//
//       final response = await dio.get(
//         UrlResources.getWalletwalletdetails,
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//           },
//         ),
//       );
//
//       print("[log] Wallet API url: ${UrlResources.getWalletwalletdetails}");
//       print("[log] Wallet API response status: ${response.statusCode}");
//       print("[log] Wallet API response body: ${response.data}");
//       print("🔵 [Wallet Details]");
//       print("➡️ URL: $UrlResources.getWalletwalletdetails");
//       print("➡️ Headers: Authorization: Bearer $token");
//       print("✅ Status Code: ${response.statusCode}");
//       print("🟢 Response Body: ${response.data}");
//       if (response.statusCode == 200) {
//         return WalletDetails.fromJson(response.data);
//       }
//       else if (response.statusCode == 401) {
//         throw UnauthorizedException("Session expired. Please log in again.");
//       } else if (response.statusCode == 400) {
//         throw BadRequestException("Invalid wallet detail request.");
//       }
//       else {
//         throw Exception('Failed to fetch wallet details');
//       }
//     } on DioException catch (e) {
//       print("[log] ❌ Wallet API error: ${e.response?.data}");
//       throw Exception(e.response?.data?['message'] ?? "Failed to fetch wallet details");
//     } catch (e) {
//       print("[log] ❌ Unknown Wallet API error: $e");
//       throw Exception('Error: ${e.toString()}');
//     }
//   }
//
//   Future<List<WalletTransaction>> fetchReceivedTransactions() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(PrefResources.USER_ACCESS_TOCKEN) ?? '';
//
//     final response = await dio.get(
//       "https://backend.kleanit.ae/api/customer/profile/transactions/received",
//       // "https://kleanit.planetprouae.com/api/customer/profile/transactions/received",
//       options: Options(headers: {'Authorization': 'Bearer $token'}),
//     );
//     print("🔵 [Received Transactions]");
//     print("➡️ URL:$UrlResources.");
//     print("➡️ Headers: Authorization: Bearer $token");
//     print("✅ Status Code: ${response.statusCode}");
//     print("🟢 Response Body: ${response.data}");
//     if (response.statusCode == 200 && response.data['success']) {
//       return (response.data['data'] as List)
//           .map((json) => WalletTransaction.fromJson(json, isReceived: true))
//           .toList();
//     }
//     else if (response.statusCode == 401) {
//       throw UnauthorizedException("Session expired. Please log in again.");
//     } else if (response.statusCode == 400) {
//       throw BadRequestException("Invalid transaction request.");
//     }
//     else {
//       throw Exception("Failed to fetch received transactions");
//     }
//   }
//
//   Future<List<WalletTransaction>> fetchSentTransactions() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(PrefResources.USER_ACCESS_TOCKEN) ?? '';
//
//     final response = await dio.get(
//       "https://backend.kleanit.ae/api/customer/profile/transactions/sent",
//       options: Options(headers: {'Authorization': 'Bearer $token'}),
//     );
//     print("🔵 [Sent Transactions]");
//     print("➡️ URL: $UrlResources");
//     print("➡️ Headers: Authorization: Bearer $token");
//     print("✅ Status Code: ${response.statusCode}");
//     print("🟢 Response Body: ${response.data}");
//     if (response.statusCode == 200 && response.data['success']) {
//       return (response.data['data'] as List)
//           .map((json) => WalletTransaction.fromJson(json, isReceived: false))
//           .toList();
//     } else {
//       throw Exception("Failed to fetch sent transactions");
//     }
//   }
// }
import 'package:dio/dio.dart';
import 'package:kleanitapp/core/constants/pref_resources.dart';
import 'package:kleanitapp/core/constants/url_resources.dart';
import 'package:kleanitapp/features/home/repo/exceptions.dart' show BadRequestException, UnauthorizedException;
import 'package:shared_preferences/shared_preferences.dart';

import '../modle/wallet_details.dart';
import 'WalletTransaction.dart';

class WalletRepository {
  final dio = Dio();

  Future<double> fetchWalletBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(PrefResources.USER_ACCESS_TOCKEN) ?? '';

      final response = await dio.get(UrlResources.getWalletBalance, options: Options(headers: {'Authorization': 'Bearer $token'}));
      print("🔵 [Wallet Balance]");
      print("➡️ URL: $UrlResources");
      print("➡️ URL: $UrlResources.getWalletBalance");
      print("➡️ Headers: Authorization: Bearer $token");
      print("✅ Status Code: ${response.statusCode}");
      print("🟢 Response Body: ${response.data}");
      if (response.statusCode == 200) {
        final data = response.data;
        double balance = double.tryParse(data['wallet_amount'].toString()) ?? 0;
        return balance;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException("Session expired. Please log in again.");
      } else if (response.statusCode == 400) {
        throw BadRequestException("Invalid wallet balance request.");
      } else {
        throw Exception('Failed to fetch wallet balance');
      }
    } on DioException catch (e) {
      print("❌ [Wallet Balance] Error Response: ${e.response?.data}");
      throw Exception(e.response?.data?['message'] ?? "Failed to add to cart");
    } catch (e) {
      print("❌ [Wallet Balance] Unknown Error: $e");
      throw Exception('Error: ${e.toString()}');
    }
  }

  // ✅ New function — added safely
  Future<WalletDetails> fetchWalletDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(PrefResources.USER_ACCESS_TOCKEN) ?? '';

      final response = await dio.get(UrlResources.getWalletwalletdetails, options: Options(headers: {'Authorization': 'Bearer $token'}));

      print("[log] Wallet API url: ${UrlResources.getWalletwalletdetails}");
      print("[log] Wallet API response status: ${response.statusCode}");
      print("[log] Wallet API response body: ${response.data}");
      print("🔵 [Wallet Details]");
      print("➡️ URL: $UrlResources.getWalletwalletdetails");
      print("➡️ Headers: Authorization: Bearer $token");
      print("✅ Status Code: ${response.statusCode}");
      print("🟢 Response Body: ${response.data}");
      if (response.statusCode == 200) {
        return WalletDetails.fromJson(response.data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException("Session expired. Please log in again.");
      } else if (response.statusCode == 400) {
        throw BadRequestException("Invalid wallet detail request.");
      } else {
        throw Exception('Failed to fetch wallet details');
      }
    } on DioException catch (e) {
      print("[log] ❌ Wallet API error: ${e.response?.data}");
      throw Exception(e.response?.data?['message'] ?? "Failed to fetch wallet details");
    } catch (e) {
      print("[log] ❌ Unknown Wallet API error: $e");
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<List<WalletTransaction>> fetchReceivedTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(PrefResources.USER_ACCESS_TOCKEN) ?? '';

    final response = await dio.get(
      "https://backend.kleanit.ae/api/customer/profile/transactions/received",
      // "https://kleanit.planetprouae.com/api/customer/profile/transactions/received",
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    print("🔵 [Received Transactions]");
    print("➡️ URL:$UrlResources.");
    print("➡️ Headers: Authorization: Bearer $token");
    print("✅ Status Code: ${response.statusCode}");
    print("🟢 Response Body: ${response.data}");
    if (response.statusCode == 200 && response.data['success']) {
      return (response.data['data'] as List).map((json) => WalletTransaction.fromJson(json, isReceived: true)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException("Session expired. Please log in again.");
    } else if (response.statusCode == 400) {
      throw BadRequestException("Invalid transaction request.");
    } else {
      throw Exception("Failed to fetch received transactions");
    }
  }

  Future<List<WalletTransaction>> fetchSentTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(PrefResources.USER_ACCESS_TOCKEN) ?? '';

    final response = await dio.get("https://backend.kleanit.ae/api/customer/profile/transactions/sent", options: Options(headers: {'Authorization': 'Bearer $token'}));
    print("🔵 [Sent Transactions]");
    print("➡️ URL: $UrlResources");
    print("➡️ Headers: Authorization: Bearer $token");
    print("✅ Status Code: ${response.statusCode}");
    print("🟢 Response Body: ${response.data}");
    if (response.statusCode == 200 && response.data['success']) {
      return (response.data['data'] as List).map((json) => WalletTransaction.fromJson(json, isReceived: false)).toList();
    } else {
      throw Exception("Failed to fetch sent transactions");
    }
  }
}
