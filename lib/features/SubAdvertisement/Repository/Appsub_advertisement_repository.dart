import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../model/Appsub_advertisement_model.dart';

class AppSubAdvertisementRepository {
  final String baseUrl =
      // "https://kleanit.planetprouae.com/api/customer/advertisements/sub";
      "https://backend.kleanit.ae/api/customer/advertisements/sub";

  Future<List<AppSubAdvertisement>> fetchSubAdvertisements(String token) async {
    final url = Uri.parse(baseUrl);
    log("fetchSubAdvertisements: Request URL: $url");
    log("fetchSubAdvertisements: Request Headers: ${{"Accept": "application/json", "Content-Type": "application/json", "Authorization": "Bearer $token"}}");
    final response = await http.get(url, headers: {"Accept": "application/json", "Content-Type": "application/json", "Authorization": "Bearer $token"});
    log("fetchSubAdvertisements: response.statusCode: ${response.statusCode}");
    log("fetchSubAdvertisements: response.body: ${response.body}");
    log("fetchSubAdvertisements: Response Status Code: ${response.statusCode}");
    log("fetchSubAdvertisements: Response Headers: ${response.headers}");
    log("fetchSubAdvertisements: Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final List<dynamic> subAdsData = data['data'];
        return subAdsData.map((json) => AppSubAdvertisement.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load sub advertisements: ${data['message']}");
      }
    } else {
      throw Exception("Failed to load sub advertisements: ${response.statusCode}");
    }
  }
}
