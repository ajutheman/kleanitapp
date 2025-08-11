// // class SubAdvertisement {
// //   final int id;
// //   final String name;
// //   final String status;
// //   final String image;
// //   final String? deletedAt;
// //   final DateTime createdAt;
// //   final DateTime updatedAt;
// //   final String encryptedId;
// //
// //   SubAdvertisement({
// //     required this.id,
// //     required this.name,
// //     required this.status,
// //     required this.image,
// //     this.deletedAt,
// //     required this.createdAt,
// //     required this.updatedAt,
// //     required this.encryptedId,
// //   });
// //
// //   factory SubAdvertisement.fromJson(Map<String, dynamic> json) {
// //     return SubAdvertisement(
// //       id: json['id'],
// //       name: json['name'],
// //       status: json['status'],
// //       image: json['image'],
// //       deletedAt: json['deleted_at'],
// //       createdAt: DateTime.parse(json['created_at']),
// //       updatedAt: DateTime.parse(json['updated_at']),
// //       encryptedId: json['encrypted_id'],
// //     );
// //   }
// // }
//
// class SubAdvertisement {
//   final int id;
//   final String name;
//   final String status;
//   final String image;
//   final int? mainCategoryId;
//   final int? firstCategoryId;
//   final int? secondCategoryId;
//   final int? thirdCategoryId;
//   final int offerApplicable;
//   final int? offerPercentage;
//   final String? deletedAt;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final String encryptedId;
//
//   SubAdvertisement({
//     required this.id,
//     required this.name,
//     required this.status,
//     required this.image,
//     this.mainCategoryId,
//     this.firstCategoryId,
//     this.secondCategoryId,
//     this.thirdCategoryId,
//     required this.offerApplicable,
//     this.offerPercentage,
//     this.deletedAt,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.encryptedId,
//   });
//
//   factory SubAdvertisement.fromJson(Map<String, dynamic> json) {
//     return SubAdvertisement(
//       id: json['id'],
//       name: json['name'],
//       status: json['status'],
//       image: json['image'],
//       mainCategoryId: json['main_category_id'],
//       firstCategoryId: json['first_category_id'],
//       secondCategoryId: json['second_category_id'],
//       thirdCategoryId: json['third_category_id'],
//       offerApplicable: json['offer_applicable'],
//       offerPercentage: json['offer_percentage'],
//       deletedAt: json['deleted_at'],
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: DateTime.parse(json['updated_at']),
//       encryptedId: json['encrypted_id'],
//     );
//   }
// }

class SubAdvertisement {
  final int id;
  final int position; // ✅ ADD THIS
  final String name;
  final String status;
  final String? image;
  final int? mainCategoryId;
  final int? firstCategoryId;
  final int? secondCategoryId;
  final int? thirdCategoryId;
  final int offerApplicable;
  final int? offerPercentage;
  final String? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String encryptedId;
  final bool isUsed;

  SubAdvertisement({
    required this.id,
    required this.position, // ✅
    required this.name,
    required this.status,
    this.image,
    this.mainCategoryId,
    this.firstCategoryId,
    this.secondCategoryId,
    this.thirdCategoryId,
    required this.offerApplicable,
    this.offerPercentage,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.encryptedId,
    required this.isUsed,
  });

  factory SubAdvertisement.fromJson(Map<String, dynamic> json) {
    return SubAdvertisement(
      id: json['id'],
      position: json['position'] ?? 0,
      // ✅ Extract position
      name: json['name'],
      status: json['status'],
      image: json['image'],
      mainCategoryId: json['main_category_id'],
      firstCategoryId: json['first_category_id'],
      secondCategoryId: json['second_category_id'],
      thirdCategoryId: json['third_category_id'],
      offerApplicable: json['offer_applicable'],
      offerPercentage: json['offer_percentage'],
      deletedAt: json['deleted_at'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      encryptedId: json['encrypted_id'],
      isUsed: json['is_used'] ?? false,
    );
  }
}
