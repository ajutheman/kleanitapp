// customer_model.dart
class Customer {
  final int id;
  final String name;
  final String email;
  final String mobile;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      mobile: json["mobile"] ?? "",
    );
  }
}
