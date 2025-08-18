class AppOTPVerificationResponse {
  final String message;
  final String token;
  final int customerId;

  AppOTPVerificationResponse({required this.message, required this.token, required this.customerId});

  factory AppOTPVerificationResponse.fromJson(Map<String, dynamic> json) {
    return AppOTPVerificationResponse(message: json["message"], token: json["token"], customerId: json["customer_id"]);
  }
}
