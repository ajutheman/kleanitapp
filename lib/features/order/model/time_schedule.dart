// // class TimeSchedule {
// //   final int id;
// //   final String scheduleTime;
// //
// //   TimeSchedule({
// //     required this.id,
// //     required this.scheduleTime,
// //   });
// //
// //   factory TimeSchedule.fromJson(Map<String, dynamic> json) {
// //     return TimeSchedule(
// //       id: json['id'],
// //       scheduleTime: json['schedule_time'],
// //     );
// //   }
// //
// //   Map<String, dynamic> toJson() {
// //     return {
// //       'id': id,
// //       'schedule_time': scheduleTime,
// //     };
// //   }
// // }
//
// class TimeSchedule {
//   final int id;
//   final String scheduleTime;
//   final int availableSlots;
//   final bool available;
//
//   TimeSchedule({
//     required this.id,
//     required this.scheduleTime,
//     required this.availableSlots,
//     required this.available,
//   });
//
//   factory TimeSchedule.fromJson(Map<String, dynamic> json) {
//     return TimeSchedule(
//       id: json['id'],
//       scheduleTime: json['schedule_time'],
//       availableSlots: json['available_slots'] ?? 0,
//       available: json['available'] ?? false,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'schedule_time': scheduleTime,
//       'available_slots': availableSlots,
//       'available': available,
//     };
//   }
// }

// class TimeSchedule {
//   final int id;
//   final String scheduleTime;
//   final int availableSlots;
//   final bool available;
//
//   TimeSchedule({
//     required this.id,
//     required this.scheduleTime,
//     required this.availableSlots,
//     required this.available,
//   });
//
//   factory TimeSchedule.fromJson(Map<String, dynamic> json) {
//     return TimeSchedule(
//       id: json['id'] ?? 0,
//       scheduleTime: json['schedule_time'] ?? '',
//       availableSlots: json['available_slots'] ?? 0,
//       available: json['available'] ?? false,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'schedule_time': scheduleTime,
//       'available_slots': availableSlots,
//       'available': available,
//     };
//   }
// }

class TimeSchedule {
  final List<int> ids;
  final String scheduleTime;
  final String scheduleTimeRaw;
  final int availableSlots;
  final bool available;
  final int totalSchedules;

  TimeSchedule({required this.ids, required this.scheduleTime, required this.scheduleTimeRaw, required this.availableSlots, required this.available, required this.totalSchedules});

  factory TimeSchedule.fromJson(Map<String, dynamic> json) {
    return TimeSchedule(
      ids: List<int>.from(json['ids'] ?? []),
      scheduleTime: json['schedule_time'] ?? '',
      scheduleTimeRaw: json['schedule_time_raw'] ?? '',
      availableSlots: json['available_slots'] ?? 0,
      available: json['available'] ?? false,
      totalSchedules: json['total_schedules'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ids': ids,
      'schedule_time': scheduleTime,
      'schedule_time_raw': scheduleTimeRaw,
      'available_slots': availableSlots,
      'available': available,
      'total_schedules': totalSchedules,
    };
  }

  /// Optionally, if you want just one ID for simplified usage
  int get primaryId => ids.isNotEmpty ? ids.first : 0;
}
