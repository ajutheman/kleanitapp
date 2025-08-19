
// class AppOrderCalculation {
//   final double subtotal;
//   final double couponDiscount;
//   final double taxableAmount;
//   final double taxRate;
//   final double taxAmount;
//   final double grandTotal;
//   final double requiredAmount;
//   final double walletAmount;
//   final double walletCoin;
//   final List<OrderCalculationItem> items;

//   AppOrderCalculation({
//     required this.subtotal,
//     required this.couponDiscount,
//     required this.taxableAmount,
//     required this.taxRate,
//     required this.taxAmount,
//     required this.grandTotal,
//     required this.requiredAmount,
//     required this.walletAmount,
//     required this.walletCoin,
//     required this.items,
//   });

//   factory AppOrderCalculation.fromJson(Map<String, dynamic> json) {
//     final orderJson = json['order_calculation'];
//     return AppOrderCalculation(
//       subtotal: double.tryParse(orderJson['subtotal'].toString()) ?? 0.0,
//       couponDiscount: double.tryParse(orderJson['coupon_discount'].toString()) ?? 0.0,
//       taxableAmount: double.tryParse(orderJson['taxable_amount'].toString()) ?? 0.0,
//       taxRate: double.tryParse(orderJson['tax_rate'].toString()) ?? 0.0,
//       taxAmount: double.tryParse(orderJson['tax_amount'].toString()) ?? 0.0,
//       grandTotal: double.tryParse(orderJson['grand_total'].toString()) ?? 0.0,
//       requiredAmount: double.tryParse(orderJson['required_amount'].toString()) ?? 0.0,
//       walletAmount: double.tryParse(orderJson['wallet_amount'].toString()) ?? 0.0,
//       walletCoin: double.tryParse(orderJson['wallet_coins_sum'].toString()) ?? 0.0,
//       items: (orderJson['items'] as List).map((item) => OrderCalculationItem.fromJson(item)).toList(),
//     );
//   }
// }

// class OrderCalculationItem {
//   final String cartId;
//   final String thirdCategoryId;
//   final String thirdCategoryName;
//   final int employeeCount;
//   final String type;
//   final int? durationMonths;
//   final double basePrice;
//   final double? perMonthTotal;
//   final double totalPrice;
//   final double additionalEmployeeCost;
//   final double offerDiscount;
//   final double itemTotal;

//   OrderCalculationItem({
//     required this.cartId,
//     required this.thirdCategoryId,
//     required this.thirdCategoryName,
//     required this.employeeCount,
//     required this.type,
//     required this.durationMonths,
//     required this.basePrice,
//     this.perMonthTotal,
//     required this.totalPrice,
//     required this.additionalEmployeeCost,
//     required this.offerDiscount,
//     required this.itemTotal,
//   });

//   factory OrderCalculationItem.fromJson(Map<String, dynamic> json) {
//     return OrderCalculationItem(
//       cartId: json['cart_id'] ?? '',
//       thirdCategoryId: json['third_category_id'] ?? '',
//       thirdCategoryName: json['third_category_name'] ?? '',
//       employeeCount: json['employee_count'] ?? 0,
//       type: json['type'] ?? '',
//       durationMonths: json['duration_months'],
//       basePrice: double.tryParse(json['base_price'].toString()) ?? 0.0,
//       perMonthTotal: json['per_month_total'] != null ? double.tryParse(json['per_month_total'].toString()) : null,
//       totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
//       additionalEmployeeCost: double.tryParse(json['additional_employee_cost'].toString()) ?? 0.0,
//       offerDiscount: double.tryParse(json['offer_discount'].toString()) ?? 0.0,
//       itemTotal: double.tryParse(json['item_total'].toString()) ?? 0.0,
//     );
//   }
// }
// ---- Small parsing helpers (put at top of the file) ----

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

int? _toIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

// ===================== ORDER CALCULATION =====================

class AppOrderCalculation {
  final double subtotal;
  final double couponDiscount;
  final double taxableAmount;
  final double taxRate;      // e.g. 5.00 means 5%
  final double taxAmount;
  final double grandTotal;
  final double requiredAmount;
  final double walletAmount;
  final double walletCoin;   // wallet_coins_sum
  final List<OrderCalculationItem> items;

  AppOrderCalculation({
    required this.subtotal,
    required this.couponDiscount,
    required this.taxableAmount,
    required this.taxRate,
    required this.taxAmount,
    required this.grandTotal,
    required this.requiredAmount,
    required this.walletAmount,
    required this.walletCoin,
    required this.items,
  });

  factory AppOrderCalculation.fromJson(Map<String, dynamic> json) {
    final orderJson = json['order_calculation'] ?? json;
    final rawItems = (orderJson['items'] as List?) ?? const [];

    return AppOrderCalculation(
      subtotal: _toDouble(orderJson['subtotal']),
      couponDiscount: _toDouble(orderJson['coupon_discount']),
      taxableAmount: _toDouble(orderJson['taxable_amount']),
      taxRate: _toDouble(orderJson['tax_rate']),
      taxAmount: _toDouble(orderJson['tax_amount']),
      grandTotal: _toDouble(orderJson['grand_total']),
      requiredAmount: _toDouble(orderJson['required_amount']),
      walletAmount: _toDouble(orderJson['wallet_amount']),
      walletCoin: _toDouble(orderJson['wallet_coins_sum']),
      items: rawItems.map((e) => OrderCalculationItem.fromJson(e)).toList(),
    );
  }
}

// ===================== ITEM =====================

class OrderCalculationItem {
  final String cartId;
  final String thirdCategoryId;
  final String thirdCategoryName;
  final int employeeCount;

  /// "subscription" or "one-time" etc.
  final String type;

  /// API: "subscription_frequency": "6" (days/week). Null for non-subscription
  final int? subscriptionFrequency;

  /// API: "duration_months": 1 (nullable; default to 1 when computing)
  final int? durationMonths;

  /// Base price per visit, e.g. "56.00"
  final double basePrice;

  /// API may supply per_month_total. If null, we compute it.
  final double? perMonthTotal;

  final double totalPrice;
  final double additionalEmployeeCost;
  final double offerDiscount;
  final double itemTotal;

  OrderCalculationItem({
    required this.cartId,
    required this.thirdCategoryId,
    required this.thirdCategoryName,
    required this.employeeCount,
    required this.type,
    required this.subscriptionFrequency,
    required this.durationMonths,
    required this.basePrice,
    this.perMonthTotal,
    required this.totalPrice,
    required this.additionalEmployeeCost,
    required this.offerDiscount,
    required this.itemTotal,
  });

  factory OrderCalculationItem.fromJson(Map<String, dynamic> json) {
    return OrderCalculationItem(
      cartId: json['cart_id']?.toString() ?? '',
      thirdCategoryId: json['third_category_id']?.toString() ?? '',
      thirdCategoryName: json['third_category_name']?.toString() ?? '',
      employeeCount: _toIntOrNull(json['employee_count']) ?? 0,
      type: json['type']?.toString() ?? '',
      subscriptionFrequency: _toIntOrNull(json['subscription_frequency']),
      durationMonths: _toIntOrNull(json['duration_months']),
      basePrice: _toDouble(json['base_price']),
      perMonthTotal: json['per_month_total'] == null ? null : _toDouble(json['per_month_total']),
      totalPrice: _toDouble(json['total_price']),
      additionalEmployeeCost: _toDouble(json['additional_employee_cost']),
      offerDiscount: _toDouble(json['offer_discount']),
      itemTotal: _toDouble(json['item_total']),
    );
  }

  // ----------------- Convenience getters -----------------

  bool get isSubscription => type.toLowerCase() == 'subscription';

  /// Days per week (0 if null).
  int get freqPerWeek => subscriptionFrequency ?? 0;

  /// Defaults to 1 when missing.
  int get months => durationMonths ?? 1;

  /// Backend math in your sample uses 4 weeks/month.
  int get visitsPerMonth => isSubscription ? freqPerWeek * 4 : 0;

  /// Uses API's per_month_total when present; else computes basePrice × freq × 4.
  double get perMonthTotalEffective =>
      perMonthTotal ?? (basePrice * visitsPerMonth);

  /// Friendly label for UI chips
  String get frequencyLabel =>
      isSubscription ? '$freqPerWeek day(s)/week' : 'One-time';

  /// For amount lines where you want the item’s final amount
  double get effectiveItemTotal => itemTotal != 0 ? itemTotal : totalPrice;
}
