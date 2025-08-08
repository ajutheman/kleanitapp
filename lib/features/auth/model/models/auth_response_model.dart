// lib/data/models/auth_response_model.dart

class AuthResponse {
  final String message;
  final String token;
  final Customer customer;

  AuthResponse({
    required this.message,
    required this.token,
    required this.customer,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] as String,
      token: json['token'] as String,
      customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
      'customer': customer.toJson(),
    };
  }
}

class Customer {
  final int id;
  final String name;
  final String email;
  final String? mobile;
  final String? otp;
  final String? otpExpiry;
  final String googleId;
  final String status;
  final String? latitude;
  final String? longitude;
  final String isLocationSelected;
  final String serviceAvailable;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String encryptedId;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
    this.otp,
    this.otpExpiry,
    required this.googleId,
    required this.status,
    this.latitude,
    this.longitude,
    required this.isLocationSelected,
    required this.serviceAvailable,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.encryptedId,
  });

  // factory Customer.fromJson(Map<String, dynamic> json) {
  //   return Customer(
  //     id: json['id'] as int,
  //     name: json['name'] as String,
  //     email: json['email'] as String,
  //     mobile: json['mobile'] as String?,
  //     otp: json['otp'] as String?,
  //     otpExpiry: json['otp_expiry'] as String?,
  //     googleId: json['google_id'] as String,
  //     status: json['status'] as String,
  //     latitude: json['latitude'] as String?,
  //     longitude: json['longitude'] as String?,
  //     isLocationSelected: json['is_location_selected'] as String,
  //     serviceAvailable: json['service_available'] as String,
  //     createdAt: json['created_at'] as String,
  //     updatedAt: json['updated_at'] as String,
  //     deletedAt: json['deleted_at'] as String?,
  //     encryptedId: json['encrypted_id'] as String,
  //   );
  // }
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile']?.toString(),
      otp: json['otp']?.toString(),
      otpExpiry: json['otp_expiry']?.toString(),
      googleId: json['google_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      isLocationSelected: json['is_location_selected']?.toString() ?? '0',
      serviceAvailable: json['service_available']?.toString() ?? '0',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString(),
      encryptedId: json['encrypted_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'otp': otp,
      'otp_expiry': otpExpiry,
      'google_id': googleId,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'is_location_selected': isLocationSelected,
      'service_available': serviceAvailable,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'encrypted_id': encryptedId,
    };
  }
}
