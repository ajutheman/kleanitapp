// lib/core/constants/url_resources.dart
class UrlResources {
  // static const String baseUrl = "https://kleanit.planetprouae.com";
  static const String baseUrl = "https://backend.kleanit.ae";
  static const String api = "$baseUrl/api/";
  static const String login = "${api}customer/login-google";
  static const String loginOtp = "${api}customer/login-otp";
  static const String verifyOtp = "${api}customer/verify-otp";
  static const String setLocation = "${api}customer/locations/set-location";
  static const String bookingList = "${api}customer/orders/list";
  static const String orderDetails = "${api}customer/orders/get";
  static const String cancelOrder = "${api}customer/orders/cancel";
  static const String scheduleDays = "${api}customer/weekly-schedule/list";
  static const String scheduleUpdate = "${api}customer/weekly-schedule/update";

// static const String login = "${api}login";
// static const String shopList = "${api}employee/shop/list";
// static const String shopDetails = "${api}employee/shop/get-shop";
// static const String ordersave = "${api}employee/order/save";
// Add additional endpoints here.
}
