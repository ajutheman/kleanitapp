class UrlResources {
  // static const String baseUrl = "https://kleanit.planetprouae.com/api";
  static const String baseUrl = "https://backend.kleanit.ae/api";
  // static const String baseUrl = "https://kleanit.planetprouae.com";
  // static const String api = "$baseUrl/api";
  static const String api = "$baseUrl";
  static const String getCartList = "$baseUrl/customer/cart/list";
  static const String addToCart = "$baseUrl/customer/cart/add";
  static const String updateCart = "$baseUrl/customer/cart/update";
  static const String removeCart = "$baseUrl/customer/cart/remove";
  static const String calculateOrder = "$baseUrl/customer/cart/calculate-order";
  static const String saveOrder = "$baseUrl/customer/orders/save";
  static const String addressList = "$baseUrl/customer/add-address/list";
  static const String addAddress = "$baseUrl/customer/add-address/save";
  static const String updateAddress = "$baseUrl/customer/add-address/update";
  static const String getScheduleList =
      "$baseUrl/customer/cart/list-time-schedules";
  static const String fetchProfile = "$baseUrl/customer/profile";
  static const String updateProfile = "$baseUrl/customer/profile/update";
  static const String reviewList = "$baseUrl/customer/reviews/customer-reviews";
  static const String reviewUpdate =
      "$baseUrl/customer/reviews/add-customer-review";
  static const String tokenUpdate =
      "$baseUrl/customer/notification/fcm/register-token";
  static const String getWalletBalance =
      "$baseUrl/customer/profile/wallet-balance";
  static const String getWalletwalletdetails =
      "$baseUrl/customer/profile/wallet-details";
  static const String notificationList =
      "$baseUrl/customer/notification/list-notifications";
  static const String faqList = "$baseUrl/customer/faqs";
  static const String validateCoupon = "$baseUrl/customer/coupon-validate";

  static const String deleteAddress =
      "$baseUrl/customer/add-address/delete"; // 👈 added
}
