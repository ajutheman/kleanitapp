import '../../categories/modle/Appcategory_detail_model.dart';

class AppCart {
  final String id;
  final String thirdCategoryId;
  final ThirdCategory thirdCategory;
  final int employeeCount;
  final String type;
  final String subscriptionFrequency;

  AppCart({required this.id, required this.thirdCategoryId, required this.thirdCategory, required this.employeeCount, required this.type, required this.subscriptionFrequency});

  factory AppCart.fromJson(Map<String, dynamic> json) {
    return AppCart(
      id: json['id'] ?? '',
      thirdCategoryId: json['third_category_id'] ?? '',
      thirdCategory: ThirdCategory.fromJson(json['third_category']),
      employeeCount: json['employee_count'] ?? 0,
      type: json['type'] ?? '',
      subscriptionFrequency: json['subscription_frequency'] ?? '',
    );
  }

  static List<AppCart> listFromJson(List<dynamic> data) {
    return data.map((item) => AppCart.fromJson(item)).toList();
  }
}
