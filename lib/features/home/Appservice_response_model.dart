// service_response_model.dart
class AppServiceAvailabilityResponse {
  final bool success;
  final String message;
  final String serviceAvailable;

  AppServiceAvailabilityResponse({required this.success, required this.message, required this.serviceAvailable});

  factory AppServiceAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return AppServiceAvailabilityResponse(success: json["success"] as bool, message: json["message"] as String, serviceAvailable: json["service_available"] as String);
  }
}
