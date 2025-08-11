import 'package:dio/dio.dart';
import 'package:kleanitapp/core/constants/url_resources.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/pref_resources.dart';
import '../model/address.dart';

class AddressRepository {
  final Dio dio = Dio();

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
    print("🔐 Access Token: $token");
    return token;
  }

  Future<List<CustomerAddress>> fetchAddressList() async {
    final token = await _getAccessToken();
    if (token == null) throw Exception("Unauthorized: Access token not found");

    try {
      final response = await dio.get(UrlResources.addressList, options: Options(headers: {"Authorization": "Bearer $token"}));
      print("📦 Address List Response: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = List<Map<String, dynamic>>.from(response.data['data']);
        return data.map((json) => CustomerAddress.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? "Failed to load addresses");
      }
    } on DioException catch (e) {
      print("❌ DioException in fetchAddressList: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? "Something went wrong");
    }
  }

  Future<void> saveAddress(Map<String, dynamic> payload) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception("Unauthorized: Access token not found");

    try {
      final response = await dio.post(UrlResources.addAddress, data: payload, options: Options(headers: {"Authorization": "Bearer $token"}));
      print("✅ Save Address Response: ${response.data}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data['message'] ?? "Failed to save address");
      }
    } on DioException catch (e) {
      print("❌ DioException in saveAddress: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? "Save address failed");
    }
  }

  Future<void> updateAddress(String encryptedId, Map<String, dynamic> payload) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception("Unauthorized: Access token not found");

    try {
      final response = await dio.post("${UrlResources.updateAddress}/$encryptedId", data: payload, options: Options(headers: {"Authorization": "Bearer $token"}));
      print("🔄 Update Address Response: ${response.data}");

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? "Update failed");
      }
    } on DioException catch (e) {
      print("❌ DioException in updateAddress: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? "Update address failed");
    }
  }

  Future<String> deleteAddress(String encryptedId) async {
    if (encryptedId.isEmpty) {
      throw Exception("Invalid address ID");
    }

    final token = await _getAccessToken();
    if (token == null) throw Exception("Unauthorized: Access token not found");

    final url = "${UrlResources.deleteAddress}/$encryptedId";
    print("🗑️ Sending DELETE request to: $url");

    try {
      final response = await dio.request(
        url,
        data: {"isDeleted": true}, // 👈 boolean true, not int 1

        options: Options(method: 'GET', headers: {"Authorization": "Bearer $token", "Accept": "application/json", "Content-Type": "application/json"}),
      );

      print("🧾 Delete Address Response: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['message'] ?? "Address deleted successfully";
      } else {
        throw Exception(response.data['message'] ?? "Could not delete address");
      }
    } on DioException catch (e) {
      final raw = e.response?.data;
      print("❌ DioException in deleteAddress: $raw");

      if (raw is Map && raw.containsKey('message')) {
        throw Exception(raw['message']);
      } else {
        throw Exception("Address deletion failed. Please try again.");
      }
    }
  }
}
