// main_category_model.dart
class MainCategory {
  final int id;
  final String name;
  final String image;
  final String status;
  final String encryptedId;

  MainCategory({required this.id, required this.name, required this.image, required this.status, required this.encryptedId});

  factory MainCategory.fromJson(Map<String, dynamic> json) {
    return MainCategory(id: json["id"], name: json["name"], image: json["image"], status: json["status"], encryptedId: json["encrypted_id"]);
  }
}
