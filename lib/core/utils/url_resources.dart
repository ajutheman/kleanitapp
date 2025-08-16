// lib/core/constants/Sypdo_url_resources.dart
class AppUrlResources {
  // static const String baseUrl = "https://kleanit.planetprouae.com";
  static const String AppbaseUrl = "https://backend.kleanit.ae";
  static const String Appapi = "$AppbaseUrl/api/";
  static const String Applogin = "${Appapi}customer/login-google";
  static const String ApploginOtp = "${Appapi}customer/login-otp";
  static const String AppverifyOtp = "${Appapi}customer/verify-otp";
  static const String AppsetLocation = "${Appapi}customer/locations/set-location";
  static const String AppbookingList = "${Appapi}customer/orders/list";
  static const String ApporderDetails = "${Appapi}customer/orders/get";
  static const String AppcancelOrder = "${Appapi}customer/orders/cancel";
  static const String AppscheduleDays = "${Appapi}customer/weekly-schedule/list";
  static const String AppscheduleUpdate = "${Appapi}customer/weekly-schedule/update";

  // static const String login = "${api}login";
  // static const String shopList = "${api}employee/shop/list";
  // static const String shopDetails = "${api}employee/shop/get-shop";
  // static const String ordersave = "${api}employee/order/save";
  // Add additional endpoints here.
}
