import 'package:equatable/equatable.dart';

import '../model/weekly_schedule.dart';

abstract class WeeklyScheduleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchWeeklySchedule extends WeeklyScheduleEvent {
  final String orderId;

  FetchWeeklySchedule({required this.orderId});
}

class UpdateWeeklySchedule extends WeeklyScheduleEvent {
  final int id;
  final WeeklyScheduleDays days;

  UpdateWeeklySchedule({required this.id, required this.days});
}
