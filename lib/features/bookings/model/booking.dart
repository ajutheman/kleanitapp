

class BookingModel {
  final String id;
  final String orderNumber;
  final double total;
  final String paymentStatus;
  final String orderStatus;
  final bool hasSubscription;
  final String schedule;

  // final TimeSchedule schedule;
  final String bookingDate; // 👈 NEW
  final int itemsCount; // 👈 NEW
  final List<BookingItem> items;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.orderNumber,
    required this.total,
    required this.paymentStatus,
    required this.orderStatus,
    required this.hasSubscription,
    required this.schedule,
    required this.bookingDate,
    required this.itemsCount,
    required this.items,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      orderNumber: json['order_number'],
      createdAt: DateTime.parse(json['created_at']),
      total: (json['total'] as num).toDouble(),
      paymentStatus: json['payment_status'],
      orderStatus: json['order_status'],
      hasSubscription: json['has_subscription'],
      // schedule: TimeSchedule.fromJson(json['scheduled_time']),
      // schedule: json['scheduled_time']?['schedule_time'] ?? '',  // ✅ FIXED
      bookingDate: json['booking_date'] ?? '',
      itemsCount: json['items_count'] ?? 0,
      schedule: json['scheduled_time']?.toString() ?? '',

      items: (json['items'] as List).map((e) => BookingItem.fromJson(e)).toList(),
    );
  }
}

class BookingItem {
  final String thirdCategoryName;
  final String type;

  BookingItem({required this.thirdCategoryName, required this.type});

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(thirdCategoryName: json['third_category_name'], type: json['type']);
  }
}
