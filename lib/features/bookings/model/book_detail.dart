// class BookingDetails {
//   final String id;
//   final String orderNumber;
//   final String createdAt;
//   final double subtotal;
//   final double taxRate;
//   final double taxAmount;
//   final double total;
//   final String paymentMethod;
//   final String paymentStatus;
//   final String orderStatus;
//   final bool hasSubscription;
//   final Address address;
//   final ScheduledTime scheduledTime;
//   final List<BookingDetailsItem> items;
//
//   BookingDetails({
//     required this.id,
//     required this.orderNumber,
//     required this.createdAt,
//     required this.subtotal,
//     required this.taxRate,
//     required this.taxAmount,
//     required this.total,
//     required this.paymentMethod,
//     required this.paymentStatus,
//     required this.orderStatus,
//     required this.hasSubscription,
//     required this.address,
//     required this.scheduledTime,
//     required this.items,
//   });
//
//   factory BookingDetails.fromJson(Map<String, dynamic> json) {
//     return BookingDetails(
//       id: json['id'],
//       orderNumber: json['order_number'],
//       createdAt: json['created_at'],
//       subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
//       taxRate: double.tryParse(json['tax_rate'].toString()) ?? 0,
//       taxAmount: double.tryParse(json['tax_amount'].toString()) ?? 0,
//       total: double.tryParse(json['total'].toString()) ?? 0,
//       paymentMethod: json['payment_method'],
//       paymentStatus: json['payment_status'],
//       orderStatus: json['order_status'],
//       hasSubscription: json['has_subscription'],
//       address: Address.fromJson(json['address']),
//       scheduledTime: ScheduledTime.fromJson(json['scheduled_time']),
//       items: (json['items'] as List).map((item) => BookingDetailsItem.fromJson(item)).toList(),
//     );
//   }
// }
//
// class Address {
//   final int id;
//   final String buildingName;
//   final String flatNumber;
//   final String floorNumber;
//   final String streetName;
//   final String area;
//   final String landmark;
//   final String emirate;
//   final String makaniNumber;
//   final String poBox;
//   final String additionalDirections;
//
//   Address({
//     required this.id,
//     required this.buildingName,
//     required this.flatNumber,
//     required this.floorNumber,
//     required this.streetName,
//     required this.area,
//     required this.landmark,
//     required this.emirate,
//     required this.makaniNumber,
//     required this.poBox,
//     required this.additionalDirections,
//   });
//
//   factory Address.fromJson(Map<String, dynamic> json) {
//     return Address(
//       id: json['id'],
//       buildingName: json['building_name'],
//       flatNumber: json['flat_number'],
//       floorNumber: json['floor_number'],
//       streetName: json['street_name'],
//       area: json['area'],
//       landmark: json['landmark'],
//       emirate: json['emirate'],
//       makaniNumber: json['makani_number'],
//       poBox: json['po_box'],
//       additionalDirections: json['additional_directions'],
//     );
//   }
// }
//
// class ScheduledTime {
//   final int id;
//   final String scheduleTime;
//   final String status;
//
//   ScheduledTime({required this.id, required this.scheduleTime, required this.status});
//
//   factory ScheduledTime.fromJson(Map<String, dynamic> json) {
//     return ScheduledTime(
//       id: json['id'],
//       scheduleTime: json['schedule_time'],
//       status: json['status'],
//     );
//   }
// }
//
// class BookingDetailsItem {
//   final String id;
//   final ThirdCategory thirdCategory;
//   final int employeeCount;
//   final String type;
//   final double basePrice;
//   final double additionalEmployeeCost;
//   final double itemTotal;
//
//   BookingDetailsItem({
//     required this.id,
//     required this.thirdCategory,
//     required this.employeeCount,
//     required this.type,
//     required this.basePrice,
//     required this.additionalEmployeeCost,
//     required this.itemTotal,
//   });
//
//   factory BookingDetailsItem.fromJson(Map<String, dynamic> json) {
//     return BookingDetailsItem(
//       id: json['id'],
//       thirdCategory: ThirdCategory.fromJson(json['third_category']),
//       employeeCount: json['employee_count'],
//       type: json['type'],
//       basePrice: double.tryParse(json['base_price'].toString()) ?? 0,
//       additionalEmployeeCost: double.tryParse(json['additional_employee_cost'].toString()) ?? 0,
//       itemTotal: double.tryParse(json['item_total'].toString()) ?? 0,
//     );
//   }
// }
//
// class ThirdCategory {
//   final int id;
//   final int secondCatId;
//   final String name;
//   final String status;
//   final String type;
//   final String image;
//   final double price;
//
//   ThirdCategory({
//     required this.id,
//     required this.secondCatId,
//     required this.name,
//     required this.status,
//     required this.type,
//     required this.image,
//     required this.price,
//   });
//
//   factory ThirdCategory.fromJson(Map<String, dynamic> json) {
//     return ThirdCategory(
//       id: json['id'],
//       secondCatId: json['second_category_id'],
//       name: json['name'],
//       status: json['status'],
//       type: json['type'],
//       image: json['image'],
//       price: double.tryParse(json['price'].toString()) ?? 0,
//     );
//   }
// }

class BookingDetails {
  final String id;
  final String orderNumber;
  final String createdAt;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final bool hasSubscription;
  final Address address;
  // final ScheduledTime scheduledTime;
  final String scheduledTime;
  final List<BookingDetailsItem> items;

  BookingDetails({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.hasSubscription,
    required this.address,
    required this.scheduledTime,
    required this.items,
  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) {
    return BookingDetails(
      id: json['id'] ?? '',
      orderNumber: json['order_number'] ?? '',
      createdAt: json['created_at'] ?? '',
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      taxRate: double.tryParse(json['tax_rate']?.toString() ?? '0') ?? 0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      orderStatus: json['order_status'] ?? '',
      hasSubscription: json['has_subscription'] ?? false,
      address: Address.fromJson(json['address'] ?? {}),
      // scheduledTime: ScheduledTime.fromJson(json['scheduled_time'] ?? {}),
      scheduledTime: json['scheduled_time'] ?? '',

      items: (json['items'] as List<dynamic>?)
              ?.map((e) => BookingDetailsItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Address {
  final int id;
  final String? buildingName;
  final String? flatNumber;
  final String? floorNumber;
  final String? streetName;
  final String? area;
  final String? landmark;
  final String? emirate;
  final String? makaniNumber;
  final String? poBox;
  final String? additionalDirections;

  Address({
    required this.id,
    this.buildingName,
    this.flatNumber,
    this.floorNumber,
    this.streetName,
    this.area,
    this.landmark,
    this.emirate,
    this.makaniNumber,
    this.poBox,
    this.additionalDirections,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      buildingName: json['building_name'],
      flatNumber: json['flat_number'],
      floorNumber: json['floor_number'],
      streetName: json['street_name'],
      area: json['area'],
      landmark: json['landmark'],
      emirate: json['emirate'],
      makaniNumber: json['makani_number'],
      poBox: json['po_box'],
      additionalDirections: json['additional_directions'],
    );
  }
}

class ScheduledTime {
  final int id;
  final String scheduleTime;
  final String status;

  ScheduledTime({
    required this.id,
    required this.scheduleTime,
    required this.status,
  });

  factory ScheduledTime.fromJson(Map<String, dynamic> json) {
    return ScheduledTime(
      id: json['id'] ?? 0,
      scheduleTime: json['schedule_time'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class BookingDetailsItem {
  final String id;
  final ThirdCategory thirdCategory;
  final int employeeCount;
  final String type;
  final double basePrice;
  final double additionalEmployeeCost;
  final double itemTotal;

  BookingDetailsItem({
    required this.id,
    required this.thirdCategory,
    required this.employeeCount,
    required this.type,
    required this.basePrice,
    required this.additionalEmployeeCost,
    required this.itemTotal,
  });

  factory BookingDetailsItem.fromJson(Map<String, dynamic> json) {
    return BookingDetailsItem(
      id: json['id'] ?? '',
      thirdCategory: ThirdCategory.fromJson(json['third_category'] ?? {}),
      employeeCount: json['employee_count'] ?? 0,
      type: json['type'] ?? '',
      basePrice: double.tryParse(json['base_price']?.toString() ?? '0') ?? 0,
      additionalEmployeeCost: double.tryParse(
              json['additional_employee_cost']?.toString() ?? '0') ??
          0,
      itemTotal: double.tryParse(json['item_total']?.toString() ?? '0') ?? 0,
    );
  }
}

class ThirdCategory {
  final int id;
  final int secondCatId;
  final String name;
  final String status;
  final String type;
  final String image;
  final double price;

  ThirdCategory({
    required this.id,
    required this.secondCatId,
    required this.name,
    required this.status,
    required this.type,
    required this.image,
    required this.price,
  });

  factory ThirdCategory.fromJson(Map<String, dynamic> json) {
    return ThirdCategory(
      id: json['id'] ?? 0,
      secondCatId: json['second_category_id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      image: json['image'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }
}
