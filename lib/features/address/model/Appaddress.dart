

class AppCustomerAddress {
  final int id;
  final int customerId;
  final String buildingName;
  final String flatNumber;
  final String floorNumber;
  final String streetName;
  final String area;
  final String landmark;
  final String emirate;
  final String makaniNumber;
  final String? latitude;
  final String? longitude;
  final String additionalDirections;
  final int isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? deletedAt;
  final int isDeleted;

  final String encryptedId;

  AppCustomerAddress({
    required this.id,
    required this.customerId,
    required this.buildingName,
    required this.flatNumber,
    required this.floorNumber,
    required this.streetName,
    required this.area,
    required this.landmark,
    required this.emirate,
    required this.makaniNumber,
    this.latitude,
    this.longitude,
    required this.additionalDirections,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isDeleted,
    required this.encryptedId,
  });

  factory AppCustomerAddress.fromJson(Map<String, dynamic> json) {
    return AppCustomerAddress(
      id: json['id'],
      customerId: json['customer_id'],
      buildingName: json['building_name'] ?? '',
      flatNumber: json['flat_number'] ?? '',
      floorNumber: json['floor_number'] ?? '',
      streetName: json['street_name'] ?? '',
      area: json['area'] ?? '',
      landmark: json['landmark'] ?? '',
      emirate: json['emirate'] ?? '',
      makaniNumber: json['makani_number'] ?? '',
      latitude: json['latitude']?.toString(),
      // nullable string
      longitude: json['longitude']?.toString(),
      // nullable string
      additionalDirections: json['additional_directions'] ?? '',
      isDefault: json['is_default'] ?? 0,
      isDeleted: json['is_deleted'] ?? 0,

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'],
      encryptedId: json['encrypted_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'building_name': buildingName,
      'flat_number': flatNumber,
      'floor_number': floorNumber,
      'street_name': streetName,
      'area': area,
      'landmark': landmark,
      'emirate': emirate,
      'makani_number': makaniNumber,
      'latitude': latitude,
      'longitude': longitude,
      'additional_directions': additionalDirections,
      'is_default': isDefault,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt,
      'encrypted_id': encryptedId,
    };
  }
}
