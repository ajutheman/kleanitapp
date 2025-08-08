// class CustomerModel {
//   final int id;
//   final String? name;
//   final String? email;
//   final String? mobile;
//   final String? status;
//   final String? latitude;
//   final String? longitude;
//
//   CustomerModel({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.mobile,
//     required this.status,
//     required this.latitude,
//     required this.longitude,
//   });
//
//   factory CustomerModel.fromJson(Map<String, dynamic> json) {
//     return CustomerModel(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       mobile: json['mobile'],
//       status: json['status'],
//       latitude: json['latitude'],
//       longitude: json['longitude'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'email': email,
//       'mobile': mobile,
//     };
//   }
// }

class CustomerModel {
  final int id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? status;
  final String? latitude;
  final String? longitude;

  CustomerModel({
    required this.id,
    this.name,
    this.email,
    this.mobile,
    this.status,
    this.latitude,
    this.longitude,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
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
