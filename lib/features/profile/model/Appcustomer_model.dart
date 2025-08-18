

class AppCustomerModel {
  final int id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? status;
  final String? latitude;
  final String? longitude;

  AppCustomerModel({required this.id, this.name, this.email, this.mobile, this.status, this.latitude, this.longitude});

  factory AppCustomerModel.fromJson(Map<String, dynamic> json) {
    return AppCustomerModel(
      id: json['id'] ?? 0,
      name: json['name'],
      email: json['email'],
      mobile: json['mobile']?.toString(),
      status: json['status'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'name': name,
  //     'email': email,
  //     'mobile': mobile,
  //   };
  // }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (mobile != null) data['mobile'] = mobile;
    return data;
  }
}
