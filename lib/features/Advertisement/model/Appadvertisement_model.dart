
class AppAdvertisement {
  final int id;
  final String name;
  final String status;
  final String image;
  final int? mainCategoryId;
  final int offerApplicable;
  final int? offerPercentage;
  final String? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String encryptedId;

  AppAdvertisement({
    required this.id,
    required this.name,
    required this.status,
    required this.image,
    this.mainCategoryId,
    required this.offerApplicable,
    this.offerPercentage,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.encryptedId,
  });

  factory AppAdvertisement.fromJson(Map<String, dynamic> json) {
    return AppAdvertisement(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      image: json['image'],
      // mainCategoryId: json['main_category_id'],
      mainCategoryId: json['main_category_id'],
      offerApplicable: json['offer_applicable'],
      offerPercentage: json['offer_percentage'],
      deletedAt: json['deleted_at'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      encryptedId: json['encrypted_id'],
    );
  }
}
