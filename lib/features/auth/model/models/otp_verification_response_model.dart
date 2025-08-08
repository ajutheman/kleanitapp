class OTPVerificationResponse {
  final String message;
  final String token;
  final int customerId;

  OTPVerificationResponse(
      {required this.message, required this.token, required this.customerId});

  factory OTPVerificationResponse.fromJson(Map<String, dynamic> json) {
    return OTPVerificationResponse(
      message: json["message"],
      token: json["token"],
      customerId: json["customer_id"],
    );
  }
}
