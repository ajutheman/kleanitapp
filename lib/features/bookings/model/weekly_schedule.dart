class WeeklySchedule {
  final int id;
  final int weekNumber;
  final WeeklyScheduleDays days;
  final DateTime startDate;
  final DateTime endDate;

  WeeklySchedule({
    required this.id,
    required this.weekNumber,
    required this.days,
    required this.startDate,
    required this.endDate,
  });

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    return WeeklySchedule(
      id: json['id'],
      weekNumber: json['week_number'],
      days: WeeklyScheduleDays.fromJson(json['days']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }
}

class WeeklyScheduleDays {
  bool sunday;
  bool monday;
  bool tuesday;
  bool wednesday;
  bool thursday;
  bool friday;
  bool saturday;

  WeeklyScheduleDays({
    required this.sunday,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
  });

  factory WeeklyScheduleDays.fromJson(Map<String, dynamic> json) {
    return WeeklyScheduleDays(
      sunday: json['sunday']['enabled'],
      monday: json['monday']['enabled'],
      tuesday: json['tuesday']['enabled'],
      wednesday: json['wednesday']['enabled'],
      thursday: json['thursday']['enabled'],
      friday: json['friday']['enabled'],
      saturday: json['saturday']['enabled'],
    );
  }

  /// ✅ Add this here
  WeeklyScheduleDays copyWith({
    bool? sunday,
    bool? monday,
    bool? tuesday,
    bool? wednesday,
    bool? thursday,
    bool? friday,
    bool? saturday,
  }) {
    return WeeklyScheduleDays(
      sunday: sunday ?? this.sunday,
      monday: monday ?? this.monday,
      tuesday: tuesday ?? this.tuesday,
      wednesday: wednesday ?? this.wednesday,
      thursday: thursday ?? this.thursday,
      friday: friday ?? this.friday,
      saturday: saturday ?? this.saturday,
    );
  }
}

class OrderDetails {
  final int id;
  final num total;
  final String? subscriptionFrequency;

  OrderDetails({
    required this.id,
    required this.total,
    this.subscriptionFrequency,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'],
      total: json['total'],
      subscriptionFrequency: json['subscription_frequency'],
    );
  }
}

class TimeSchedule {
  final int id;
  final String scheduleTime;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String encryptedId;

  TimeSchedule({
    required this.id,
    required this.scheduleTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.encryptedId,
  });

  factory TimeSchedule.fromJson(Map<String, dynamic> json) {
    return TimeSchedule(
      id: json['id'],
      scheduleTime: json['schedule_time'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      encryptedId: json['encrypted_id'],
    );
  }
}
