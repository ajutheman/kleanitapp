class OTPLoginResponse {
  final String message;
  final String mobile;

  OTPLoginResponse({required this.message, required this.mobile});

  factory OTPLoginResponse.fromJson(Map<String, dynamic> json) {
    return OTPLoginResponse(
      message: json["message"],
      mobile: json["mobile"],
    );
  }
}
