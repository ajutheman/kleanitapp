// lib/data/models/location_response_model.dart
class LocationResponse {
  final bool success;
  final String message;
  final String serviceAvailable;

  LocationResponse({
    required this.success,
    required this.message,
    required this.serviceAvailable,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      success: json["success"],
      message: json["message"],
      serviceAvailable: json["service_available"],
    );
  }
}
