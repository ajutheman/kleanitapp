import 'dart:convert';

import '../../categories/modle/category_detail_model.dart';

class Cart {
  final String id;
  final String thirdCategoryId;
  final ThirdCategory thirdCategory;
  final int employeeCount;
  final String type;
  final String subscriptionFrequency;

  Cart({
    required this.id,
    required this.thirdCategoryId,
    required this.thirdCategory,
    required this.employeeCount,
    required this.type,
    required this.subscriptionFrequency,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? '',
      thirdCategoryId: json['third_category_id'] ?? '',
      thirdCategory: ThirdCategory.fromJson(json['third_category']),
      employeeCount: json['employee_count'] ?? 0,
      type: json['type'] ?? '',
      subscriptionFrequency: json['subscription_frequency'] ?? '',
    );
  }

  static List<Cart> listFromJson(List<dynamic> data) {
    return data.map((item) => Cart.fromJson(item)).toList();
  }
}
