class TimeSlotOption {
  final String scheduleTime;        // e.g. "08:00 AM"
  final List<int> ids;              // e.g. [41]
  final String scheduleTimeRaw;     // e.g. "2025-08-16T04:00:00.000000Z"
  final int availableSlots;
  final int bookedCount;
  final int orderConflicts;
  final bool available;
  final int totalSchedules;

  TimeSlotOption({
    required this.scheduleTime,
    required this.ids,
    required this.scheduleTimeRaw,
    required this.availableSlots,
    required this.bookedCount,
    required this.orderConflicts,
    required this.available,
    required this.totalSchedules,
  });

  factory TimeSlotOption.fromJson(Map<String, dynamic> json) {
    return TimeSlotOption(
      scheduleTime: (json['schedule_time'] ?? '') as String,
      ids: ((json['ids'] as List?) ?? []).map((e) => (e as num).toInt()).toList(),
      scheduleTimeRaw: (json['schedule_time_raw'] ?? '') as String,
      availableSlots: (json['available_slots'] as num? ?? 0).toInt(),
      bookedCount: (json['booked_count'] as num? ?? 0).toInt(),
      orderConflicts: (json['order_conflicts'] as num? ?? 0).toInt(),
      available: (json['available'] ?? false) as bool,
      totalSchedules: (json['total_schedules'] as num? ?? 0).toInt(),
    );
  }
}
