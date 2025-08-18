// lib/data/models/location_response_model.dart
class AppLocationResponse {
  final bool success;
  final String message;
  final String serviceAvailable;

  AppLocationResponse({required this.success, required this.message, required this.serviceAvailable});

  factory AppLocationResponse.fromJson(Map<String, dynamic> json) {
    return AppLocationResponse(success: json["success"], message: json["message"], serviceAvailable: json["service_available"]);
  }
}
