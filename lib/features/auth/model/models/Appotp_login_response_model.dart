class AppOTPLoginResponse {
  final String message;
  final String mobile;

  AppOTPLoginResponse({required this.message, required this.mobile});

  factory AppOTPLoginResponse.fromJson(Map<String, dynamic> json) {
    return AppOTPLoginResponse(message: json["message"], mobile: json["mobile"]);
  }
}
