// // home_repository.dart
// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:http/http.dart' as http;
//
// import 'service_response_model.dart';
//
// class HomeRepository {
//   final String baseUrl =
//       "https://kleanit.planetprouae.com/api/customer/locations/set-location";
//
//   Future<ServiceAvailabilityResponse> setLocation(
//       double latitude, double longitude, String token) async {
//     final url = Uri.parse(baseUrl);
//     final response = await http.post(
//       url,
//       headers: {
//         "Authorization": "Bearer $token",
//         "Content-Type": "application/json",
//       },
//       body: jsonEncode({
//         "latitude": latitude,
//         "longitude": longitude,
//       }),
//     );
//     log("response.statusCode: $response.statusCode");
//     // if (response.statusCode == 401) {
//     //   throw Exception("Token expired");
//     // }
//     // else
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return ServiceAvailabilityResponse.fromJson(data);
//     } else {
//       throw Exception("Failed to set location: ${response.statusCode}");
//     }
//   }
// }

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:kleanitapp/features/home/repo/exceptions.dart';

import 'service_response_model.dart';

class HomeRepository {
  final String baseUrl = "https://backend.kleanit.ae/api/customer/locations/set-location";

  Future<ServiceAvailabilityResponse> setLocation(double latitude, double longitude, String token) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json", // Added Accept header
      },
      body: jsonEncode({"latitude": latitude, "longitude": longitude}),
    );
    log("response.statusCode: ${response.statusCode}");
    log("response.body: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ServiceAvailabilityResponse.fromJson(data);
    }
    if (response.statusCode == 401) {
      throw UnauthorizedException("Unauthorized: Token expired or invalid");
    } else if (response.statusCode == 400) {
      throw BadRequestException("Bad Request: Invalid location data");
    } else if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ServiceAvailabilityResponse.fromJson(data);
    } else {
      throw Exception("Failed to set location: ${response.statusCode}");
    }
    // else {
    //   throw Exception("Failed to set location: ${response.statusCode}");
    // }
  }
}
