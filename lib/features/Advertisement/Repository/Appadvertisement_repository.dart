
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../model/Appadvertisement_model.dart';

class AppAdvertisementRepository {
  final String baseUrl = "https://backend.kleanit.ae/api/customer/advertisements/main";

  // "https://kleanit.planetprouae.com/api/customer/advertisements/main";

  Future<List<AppAdvertisement>> fetchAdvertisements(String token) async {
    final url = Uri.parse(baseUrl);

    final headers = {"Accept": "application/json", "Content-Type": "application/json", "Authorization": "Bearer $token"};

    log("fetchAdvertisements: Request URL: $url");
    log("fetchAdvertisements: Request Headers: $headers");

    final response = await http.get(url, headers: headers);

    log("fetchAdvertisements: Response Status Code: ${response.statusCode}");
    log("fetchAdvertisements: Response Headers: ${response.headers}");
    log("fetchAdvertisements: Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final List<dynamic> advertisementsData = data['data'];
        return advertisementsData.map((json) => AppAdvertisement.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load advertisements: ${data['message']}");
      }
    } else {
      throw Exception("Failed to load advertisements: ${response.statusCode}");
    }
  }
}
