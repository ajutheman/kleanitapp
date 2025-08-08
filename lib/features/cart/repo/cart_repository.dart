import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:kleanit/core/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/pref_resources.dart';
import '../../../core/constants/url_resources.dart';
import '../model/cart.dart';

class CartRepository {
  final dio = Dio();

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
  }

  // ✅ Fetch Cart List
  Future<List<Cart>> fetchCartList() async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Unauthorized: Access token not found");
      }
      final url = UrlResources.getCartList;
      print("➡️ GET: $url");
      final response = await dio.get(
        UrlResources.getCartList,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      print("✅ Response [${response.statusCode}]: ${response.data}");

      if (response.statusCode == 200) {
        return Cart.listFromJson(response.data['data']);
      } else {
        throw Exception("Failed to fetch cart: ${response.data}");
      }
    } catch (e) {
      throw Exception("Error fetching cart: $e");
    }
  }

  // ✅ Add to Cart
  Future<int> addToCart({
    required int thirdCategoryId,
    required int employeeCount,
    required String type,
    required int subscriptionFrequency,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Unauthorized: Access token not found");
      }

      final payload = {
        "third_category_id": thirdCategoryId,
        "employee_count": employeeCount,
        "type": type,
        if (type == SubscriptionType.SUBSCRIPTION)
          "subscription_frequency": subscriptionFrequency,
      };
      final url = UrlResources.addToCart;
      print("➡️ POST: $url");
      print("📦 Payload: $payload");
      final response = await dio.post(
        UrlResources.addToCart,
        data: jsonEncode(payload),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
      print("✅ Response [${response.statusCode}]: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['cart']['third_category']['id'] ?? 1;
      } else {
        throw Exception("Failed to add to cart: ${response.data}");
      }
    } on DioException catch (e) {
      print("❌ DioException: ${e.response?.data}");
      throw Exception(e.response?.data?['message'] ?? "Failed to add to cart");
    } catch (e) {
      throw Exception("Error adding to cart: $e");
    }
  }

  // ✅ Update Cart
  Future<void> updateCart({
    required int cartId,
    required int thirdCategoryId,
    required int employeeCount,
    required String type,
    required int subscriptionFrequency,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Unauthorized: Access token not found");
      }

      final payload = {
        "third_category_id": thirdCategoryId,
        "employee_count": employeeCount,
        "type": type,
        "subscription_frequency": subscriptionFrequency,
      };
      final url = "${UrlResources.updateCart}/$cartId";
      print("➡️ PUT: $url");
      print("📦 Payload: $payload");
      final response = await dio.put(
        "${UrlResources.updateCart}/$cartId",
        data: jsonEncode(payload),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      print("✅ Response [${response.statusCode}]: ${response.data}");
      if (response.statusCode == 200) {
        print("Cart updated successfully");
      } else {
        throw Exception("Failed to update cart: ${response.data}");
      }
    } catch (e) {
      throw Exception("Error updating cart: $e");
    }
  }

  // ✅ Delete Cart
  Future<void> deleteCart({
    required String cartId,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Unauthorized: Access token not found");
      }
      final url = "${UrlResources.removeCart}/$cartId";
      print("➡️ DELETE: $url");
      final response = await dio.delete(
        "${UrlResources.removeCart}/$cartId",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      print("✅ Response [${response.statusCode}]: ${response.data}");
      if (response.statusCode == 200) {
        print("Cart delete successfully");
      } else {
        throw Exception("Failed to delete cart: ${response.data}");
      }
    } catch (e) {
      throw Exception("Error delete cart: $e");
    }
  }
}
