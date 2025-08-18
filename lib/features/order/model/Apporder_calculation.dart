
class AppOrderCalculation {
  final double subtotal;
  final double couponDiscount;
  final double taxableAmount;
  final double taxRate;
  final double taxAmount;
  final double grandTotal;
  final double requiredAmount;
  final double walletAmount;
  final double walletCoin;
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
    final orderJson = json['order_calculation'];
    return AppOrderCalculation(
      subtotal: double.tryParse(orderJson['subtotal'].toString()) ?? 0.0,
      couponDiscount: double.tryParse(orderJson['coupon_discount'].toString()) ?? 0.0,
      taxableAmount: double.tryParse(orderJson['taxable_amount'].toString()) ?? 0.0,
      taxRate: double.tryParse(orderJson['tax_rate'].toString()) ?? 0.0,
      taxAmount: double.tryParse(orderJson['tax_amount'].toString()) ?? 0.0,
      grandTotal: double.tryParse(orderJson['grand_total'].toString()) ?? 0.0,
      requiredAmount: double.tryParse(orderJson['required_amount'].toString()) ?? 0.0,
      walletAmount: double.tryParse(orderJson['wallet_amount'].toString()) ?? 0.0,
      walletCoin: double.tryParse(orderJson['wallet_coins_sum'].toString()) ?? 0.0,
      items: (orderJson['items'] as List).map((item) => OrderCalculationItem.fromJson(item)).toList(),
    );
  }
}

class OrderCalculationItem {
  final String cartId;
  final String thirdCategoryId;
  final String thirdCategoryName;
  final int employeeCount;
  final String type;
  final int? durationMonths;
  final double basePrice;
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
      cartId: json['cart_id'] ?? '',
      thirdCategoryId: json['third_category_id'] ?? '',
      thirdCategoryName: json['third_category_name'] ?? '',
      employeeCount: json['employee_count'] ?? 0,
      type: json['type'] ?? '',
      durationMonths: json['duration_months'],
      basePrice: double.tryParse(json['base_price'].toString()) ?? 0.0,
      perMonthTotal: json['per_month_total'] != null ? double.tryParse(json['per_month_total'].toString()) : null,
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      additionalEmployeeCost: double.tryParse(json['additional_employee_cost'].toString()) ?? 0.0,
      offerDiscount: double.tryParse(json['offer_discount'].toString()) ?? 0.0,
      itemTotal: double.tryParse(json['item_total'].toString()) ?? 0.0,
    );
  }
}
