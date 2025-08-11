import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:kleanitapp/features/Referral/referal_advertisement.dart';

class ReferalAdvertisementRepository {
  final String baseUrl =
      // "https://kleanit.planetprouae.com/api/customer/advertisements/referal";
      "https://backend.kleanit.ae/api/customer/advertisements/referal";

  Future<List<ReferalAdvertisement>> fetchReferalAdvertisements(String token) async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url, headers: {"Accept": "application/json", "Content-Type": "application/json", "Authorization": "Bearer $token"});
    log("fetchReferalAdvertisements: response.statusCode: ${response.statusCode}");
    log("fetchReferalAdvertisements: response.body: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final List<dynamic> referalData = data['data'];
        return referalData.map((json) => ReferalAdvertisement.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load referral advertisements: ${data['message']}");
      }
    } else {
      throw Exception("Failed to load referral advertisements: ${response.statusCode}");
    }
  }
}
