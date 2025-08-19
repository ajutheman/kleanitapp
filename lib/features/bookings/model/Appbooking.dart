// //
// //
// // class AppBookingModel {
// //   final String id;
// //   final String orderNumber;
// //   final double total;
// //   final String paymentStatus;
// //   final String orderStatus;
// //   final bool hasSubscription;
// //   final String schedule;
// //
// //   // final TimeSchedule schedule;
// //   final String bookingDate; // 👈 NEW
// //   final int itemsCount; // 👈 NEW
// //   final List<BookingItem> items;
// //   final DateTime createdAt;
// //
// //   AppBookingModel({
// //     required this.id,
// //     required this.orderNumber,
// //     required this.total,
// //     required this.paymentStatus,
// //     required this.orderStatus,
// //     required this.hasSubscription,
// //     required this.schedule,
// //     required this.bookingDate,
// //     required this.itemsCount,
// //     required this.items,
// //     required this.createdAt,
// //   });
// //
// //   factory AppBookingModel.fromJson(Map<String, dynamic> json) {
// //     return AppBookingModel(
// //       id: json['id'],
// //       orderNumber: json['order_number'],
// //       createdAt: DateTime.parse(json['created_at']),
// //       total: (json['total'] as num).toDouble(),
// //       paymentStatus: json['payment_status'],
// //       orderStatus: json['order_status'],
// //       hasSubscription: json['has_subscription'],
// //       // schedule: TimeSchedule.fromJson(json['scheduled_time']),
// //       // schedule: json['scheduled_time']?['schedule_time'] ?? '',  // ✅ FIXED
// //       bookingDate: json['booking_date'] ?? '',
// //       itemsCount: json['items_count'] ?? 0,
// //       schedule: json['scheduled_time']?.toString() ?? '',
// //
// //       items: (json['items'] as List).map((e) => BookingItem.fromJson(e)).toList(),
// //     );
// //   }
// // }
// //
// // class BookingItem {
// //   final String thirdCategoryName;
// //   final String type;
// //
// //   BookingItem({required this.thirdCategoryName, required this.type});
// //
// //   factory BookingItem.fromJson(Map<String, dynamic> json) {
// //     return BookingItem(thirdCategoryName: json['third_category_name'], type: json['type']);
// //   }
// // }
//
// // ---------- Top-level response ----------
// class OrdersResponse {
//   final List<AppBookingModel> orders;
//   final Pagination pagination;
//
//   OrdersResponse({required this.orders, required this.pagination});
//
//   factory OrdersResponse.fromJson(Map<String, dynamic> json) {
//     final ordersJson = (json['orders'] as List? ?? []);
//     return OrdersResponse(
//       orders: ordersJson
//           .map((e) => AppBookingModel.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
//     );
//   }
// }
//
// class Pagination {
//   final int total;
//   final int perPage;
//   final int currentPage;
//   final int lastPage;
//
//   Pagination({
//     required this.total,
//     required this.perPage,
//     required this.currentPage,
//     required this.lastPage,
//   });
//
//   factory Pagination.fromJson(Map<String, dynamic> json) {
//     return Pagination(
//       total: (json['total'] ?? 0) as int,
//       perPage: (json['per_page'] ?? 0) as int,
//       currentPage: (json['current_page'] ?? 1) as int,
//       lastPage: (json['last_page'] ?? 1) as int,
//     );
//   }
// }
//
// // ---------- Order ----------
// class AppBookingModel {
//   final String id;
//   final String orderNumber;
//   final double total;
//   final String paymentStatus;
//   final String orderStatus;
//   final bool hasSubscription;
//
//   /// Use this for time (id + "time" string)
//   final TimeSchedule scheduledTime;
//
//   /// Kept as String to match your current code pattern (e.g. "2025-11-30")
//   final String bookingDate;
//
//   final int itemsCount;
//   final List<BookingItem> items;
//   final DateTime createdAt;
//
//   /// New: weekly schedules + order schedules from API
//   final List<WeeklySchedule> weeklySchedules;
//   final List<OrderSchedule> orderSchedules;
//
//   AppBookingModel({
//     required this.id,
//     required this.orderNumber,
//     required this.total,
//     required this.paymentStatus,
//     required this.orderStatus,
//     required this.hasSubscription,
//     required this.scheduledTime,
//     required this.bookingDate,
//     required this.itemsCount,
//     required this.items,
//     required this.createdAt,
//     required this.weeklySchedules,
//     required this.orderSchedules,
//   });
//
//   /// Back-compat convenience: `model.schedule` still works
//   // String get schedule => scheduledTime.time;
//   String get schedule => scheduledTime.time ?? '';
//   factory AppBookingModel.fromJson(Map<String, dynamic> json) {
//     return AppBookingModel(
//       id: json['id'] as String,
//       orderNumber: json['order_number'] as String,
//       createdAt: DateTime.parse(json['created_at'] as String),
//       bookingDate: (json['booking_date'] ?? '') as String,
//       total: (json['total'] as num).toDouble(),
//       paymentStatus: json['payment_status'] as String,
//       orderStatus: json['order_status'] as String,
//       hasSubscription: json['has_subscription'] as bool,
//       scheduledTime: TimeSchedule.fromJson(json['scheduled_time'] as Map<String, dynamic>?),
//       itemsCount: (json['items_count'] ?? 0) as int,
//       items: ((json['items'] as List?) ?? [])
//           .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       weeklySchedules: ((json['weekly_schedules'] as List?) ?? [])
//           .map((e) => WeeklySchedule.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       orderSchedules: ((json['order_schedules'] as List?) ?? [])
//           .map((e) => OrderSchedule.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }
//
// // ---------- Nested: schedule ----------
// class TimeSchedule {
//   final int? id;      // nullable to support places where id can be null
//   final String? time; // nullable to support places where time can be null
//
//   const TimeSchedule({this.id, this.time});
//
//   factory TimeSchedule.fromJson(Map<String, dynamic>? json) {
//     if (json == null) return const TimeSchedule();
//     return TimeSchedule(
//       id: (json['id'] is int) ? json['id'] as int : (json['id'] as num?)?.toInt(),
//       time: json['time'] as String?,
//     );
//   }
// }
//
// // ---------- Nested: items ----------
// // REPLACE your BookingItem with this version
// class BookingItem {
//   final String thirdCategoryName;
//   final String type;
//   final int? employeeCount;
//
//   /// how many total occurrences (weeks or months) the plan spans
//   final int? subscriptionFrequency;
//
//   /// total occurrences purchased
//   final int subscriptionCount;
//
//   /// NEW:
//   final String? subscriptionMode;   // "weekly" | "monthly" | null
//   final int? timesPerWeek;          // if weekly
//   final int? timesPerMonth;         // if monthly
//   final int? months;                // number of months if monthly
//
//   BookingItem({
//     required this.thirdCategoryName,
//     required this.type,
//     this.employeeCount,
//     this.subscriptionFrequency,
//     required this.subscriptionCount,
//     this.subscriptionMode,
//     this.timesPerWeek,
//     this.timesPerMonth,
//     this.months,
//   });
//
//   factory BookingItem.fromJson(Map<String, dynamic> json) {
//     return BookingItem(
//       thirdCategoryName: (json['third_category_name'] ?? '') as String,
//       type: (json['type'] ?? '') as String,
//       employeeCount: (json['employee_count'] as num?)?.toInt(),
//       subscriptionFrequency: (json['subscription_frequency'] as num?)?.toInt(),
//       subscriptionCount: (json['subscription_count'] as num? ?? 0).toInt(),
//       subscriptionMode: json['subscription_mode'] as String?,
//       timesPerWeek: (json['times_per_week'] as num?)?.toInt(),
//       timesPerMonth: (json['times_per_month'] as num?)?.toInt(),
//       months: (json['months'] as num?)?.toInt(),
//     );
//   }
// }
//
// // ---------- Nested: weekly schedules ----------
// // REPLACE your WeeklySchedule with this version
// class WeeklySchedule {
//   final int id;                     // <- add this!
//   final int weekNumber;
//   final String startDate;
//   final String endDate;
//   final WeekDays days;
//   final TimeSchedule timeSchedule;
//   final String? status;
//   final bool isBooked;
//
//   WeeklySchedule({
//     required this.id,
//     required this.weekNumber,
//     required this.startDate,
//     required this.endDate,
//     required this.days,
//     required this.timeSchedule,
//     required this.status,
//     required this.isBooked,
//   });
//
//   factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
//     return WeeklySchedule(
//       id: (json['id'] ?? 0) as int,
//       weekNumber: (json['week_number'] ?? 0) as int,
//       startDate: (json['start_date'] ?? '') as String,
//       endDate: (json['end_date'] ?? '') as String,
//       days: WeekDays.fromJson(json['days'] as Map<String, dynamic>?),
//       timeSchedule: TimeSchedule.fromJson(json['time_schedule'] as Map<String, dynamic>?),
//       status: json['status'] as String?,
//       isBooked: (json['is_booked'] ?? false) as bool,
//     );
//   }
// }
//
// // Replaces the old WeekDays(mon/tue/...) with a map-backed model
// class WeekDays {
//   final Map<String, dynamic> raw;
//   WeekDays({Map<String, dynamic>? raw}) : raw = raw ?? {};
//   factory WeekDays.fromJson(Map<String, dynamic>? json) {
//     final m = <String, dynamic>{};
//     (json ?? {}).forEach((k, v) => m[k.toString()] = v);
//     return WeekDays(raw: m);
//   }
//   Iterable<String> get keys => raw.keys;
// }
//
//
//
// // ---------- Nested: order schedules ----------
// class OrderSchedule {
//   final String? scheduleDate;          // null in sample
//   final TimeSchedule? timeSchedule;    // id/time may be null
//
//   OrderSchedule({this.scheduleDate, this.timeSchedule});
//
//   factory OrderSchedule.fromJson(Map<String, dynamic> json) {
//     return OrderSchedule(
//       scheduleDate: json['schedule_date'] as String?,
//       timeSchedule: json['time_schedule'] != null
//           ? TimeSchedule.fromJson(json['time_schedule'] as Map<String, dynamic>)
//           : null,
//     );
//   }
// }
//
// ---------- Top-level response ----------
class OrdersResponse {
  final List<AppBookingModel> orders;
  final Pagination pagination;

  OrdersResponse({required this.orders, required this.pagination});

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    final ordersJson = (json['orders'] as List? ?? []);
    return OrdersResponse(
      orders: ordersJson
          .map((e) => AppBookingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}

class Pagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  Pagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: (json['total'] ?? 0) as int,
      perPage: (json['per_page'] ?? 0) as int,
      currentPage: (json['current_page'] ?? 1) as int,
      lastPage: (json['last_page'] ?? 1) as int,
    );
  }
}

// ---------- Order ----------
class AppBookingModel {
  final String id;
  final String orderNumber;
  final double total;
  final String paymentStatus;
  final String orderStatus;
  final bool hasSubscription;

  /// time (id + "time" string)
  final TimeSchedule scheduledTime;

  /// Kept as String to match your current code pattern (e.g. "2025-11-30")
  final String bookingDate;

  final int itemsCount;
  final List<BookingItem> items;
  final DateTime createdAt;

  /// From API
  final List<WeeklySchedule> weeklySchedules;
  final List<OrderSchedule> orderSchedules;

  AppBookingModel({
    required this.id,
    required this.orderNumber,
    required this.total,
    required this.paymentStatus,
    required this.orderStatus,
    required this.hasSubscription,
    required this.scheduledTime,
    required this.bookingDate,
    required this.itemsCount,
    required this.items,
    required this.createdAt,
    required this.weeklySchedules,
    required this.orderSchedules,
  });

  /// Back-compat with your UI
  String get schedule => scheduledTime.time ?? '';

  factory AppBookingModel.fromJson(Map<String, dynamic> json) {
    return AppBookingModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      bookingDate: (json['booking_date'] ?? '') as String,
      total: (json['total'] as num).toDouble(),
      paymentStatus: json['payment_status'] as String,
      orderStatus: json['order_status'] as String,
      hasSubscription: json['has_subscription'] as bool,
      scheduledTime: TimeSchedule.fromJson(json['scheduled_time'] as Map<String, dynamic>?),
      itemsCount: (json['items_count'] ?? 0) as int,
      items: ((json['items'] as List?) ?? [])
          .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      weeklySchedules: ((json['weekly_schedules'] as List?) ?? [])
          .map((e) => WeeklySchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
      orderSchedules: ((json['order_schedules'] as List?) ?? [])
          .map((e) => OrderSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ---------- Nested: schedule ----------
class TimeSchedule {
  final int? id;      // nullable
  final String? time; // nullable

  const TimeSchedule({this.id, this.time});

  factory TimeSchedule.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TimeSchedule();
    return TimeSchedule(
      id: (json['id'] is int) ? json['id'] as int : (json['id'] as num?)?.toInt(),
      time: json['time'] as String?,
    );
  }
}

// ---------- Nested: items ----------
class BookingItem {
  final String thirdCategoryName;
  final String type;
  final int? employeeCount;

  /// how many total occurrences (weeks or months) the plan spans
  final int? subscriptionFrequency;

  /// total occurrences purchased
  final int subscriptionCount;

  /// NEW
  final String? subscriptionMode;   // "weekly" | "monthly" | null
  final int? timesPerWeek;          // if weekly
  final int? timesPerMonth;         // if monthly
  final int? months;                // number of months if monthly

  BookingItem({
    required this.thirdCategoryName,
    required this.type,
    this.employeeCount,
    this.subscriptionFrequency,
    required this.subscriptionCount,
    this.subscriptionMode,
    this.timesPerWeek,
    this.timesPerMonth,
    this.months,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      thirdCategoryName: (json['third_category_name'] ?? '') as String,
      type: (json['type'] ?? '') as String,
      employeeCount: (json['employee_count'] as num?)?.toInt(),
      subscriptionFrequency: (json['subscription_frequency'] as num?)?.toInt(),
      subscriptionCount: (json['subscription_count'] as num? ?? 0).toInt(),
      subscriptionMode: json['subscription_mode'] as String?,
      timesPerWeek: (json['times_per_week'] as num?)?.toInt(),
      timesPerMonth: (json['times_per_month'] as num?)?.toInt(),
      months: (json['months'] as num?)?.toInt(),
    );
  }
}

// ---------- Nested: weekly schedules ----------
class WeeklySchedule {
  final int id;
  final int weekNumber;
  final String startDate;
  final String endDate;
  final WeekDays days;
  final TimeSchedule timeSchedule;
  final String? status;
  final bool isBooked;

  WeeklySchedule({
    required this.id,
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.timeSchedule,
    required this.status,
    required this.isBooked,
  });

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    return WeeklySchedule(
      id: (json['id'] ?? 0) as int,
      weekNumber: (json['week_number'] ?? 0) as int,
      startDate: (json['start_date'] ?? '') as String,
      endDate: (json['end_date'] ?? '') as String,
      // NOTE: tolerant to List or Map for "days"
      days: WeekDays.fromJson(json['days']),
      timeSchedule: TimeSchedule.fromJson(json['time_schedule'] as Map<String, dynamic>?),
      status: json['status'] as String?,
      isBooked: (json['is_booked'] ?? false) as bool,
    );
  }
}

/// A tolerant wrapper over the weird "days" field.
/// - If API sends a List of day objects, we index them by date.
/// - If API sends a Map date->(null|object), we normalize to the same structure.
class WeekDays {
  final Map<String, DayInfo> byDate;
  WeekDays({Map<String, DayInfo>? byDate}) : byDate = byDate ?? {};

  factory WeekDays.fromJson(dynamic json) {
    final map = <String, DayInfo>{};

    if (json is List) {
      // List of objects with "date" (and maybe id/status/time_schedule)
      for (final e in json) {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e as Map);
          final date = (m['date'] ?? '').toString();
          if (date.isNotEmpty) {
            map[date] = DayInfo.fromJson(m);
          }
        }
      }
    } else if (json is Map) {
      // Map of date -> null or date -> { id/status/time_schedule }
      json.forEach((key, value) {
        final date = key.toString();
        if (value is Map) {
          final m = Map<String, dynamic>.from(value as Map);
          // ensure the date is present inside too (helpful for DayInfo)
          m['date'] = date;
          map[date] = DayInfo.fromJson(m);
        } else {
          // just the date is available
          map[date] = DayInfo(date: date);
        }
      });
    }

    return WeekDays(byDate: map);
  }

  /// matches your UI: iterate the date strings
  Iterable<String> get keys => byDate.keys;

  /// convenience accessor
  DayInfo? operator [](String date) => byDate[date];
}

/// Normalized info per day; used internally if you need it later
class DayInfo {
  final int? id;
  final String date;
  final String? status;
  final TimeSchedule? timeSchedule;

  DayInfo({
    required this.date,
    this.id,
    this.status,
    this.timeSchedule,
  });

  factory DayInfo.fromJson(Map<String, dynamic> json) {
    return DayInfo(
      id: (json['id'] as num?)?.toInt(),
      date: (json['date'] ?? '') as String,
      status: json['status'] as String?,
      timeSchedule: json['time_schedule'] != null
          ? TimeSchedule.fromJson(json['time_schedule'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ---------- Nested: order schedules ----------
class OrderSchedule {
  final String? scheduleDate;          // may be null
  final TimeSchedule? timeSchedule;    // id/time may be null

  OrderSchedule({this.scheduleDate, this.timeSchedule});

  factory OrderSchedule.fromJson(Map<String, dynamic> json) {
    return OrderSchedule(
      scheduleDate: json['schedule_date'] as String?,
      timeSchedule: json['time_schedule'] != null
          ? TimeSchedule.fromJson(json['time_schedule'] as Map<String, dynamic>)
          : null,
    );
  }
}
