// customer_model.dart
class AppCustomer {
  final int id;
  final String name;
  final String email;
  final String mobile;

  AppCustomer({required this.id, required this.name, required this.email, required this.mobile});

  factory AppCustomer.fromJson(Map<String, dynamic> json) {
    return AppCustomer(id: json["id"], name: json["name"], email: json["email"], mobile: json["mobile"] ?? "");
  }
}
