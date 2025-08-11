// service_response_model.dart
class ServiceAvailabilityResponse {
  final bool success;
  final String message;
  final String serviceAvailable;

  ServiceAvailabilityResponse({required this.success, required this.message, required this.serviceAvailable});

  factory ServiceAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return ServiceAvailabilityResponse(success: json["success"] as bool, message: json["message"] as String, serviceAvailable: json["service_available"] as String);
  }
}
