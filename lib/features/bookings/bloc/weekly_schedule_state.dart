import 'package:equatable/equatable.dart';
import '../model/weekly_schedule.dart';

abstract class WeeklyScheduleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WeeklyScheduleInitial extends WeeklyScheduleState {}

class WeeklyScheduleLoading extends WeeklyScheduleState {}

class WeeklyScheduleLoaded extends WeeklyScheduleState {
  final List<WeeklySchedule> schedule;

  WeeklyScheduleLoaded({required this.schedule});

  @override
  List<Object?> get props => [schedule];
}

class WeeklyScheduleSuccess extends WeeklyScheduleState {}

class WeeklyScheduleError extends WeeklyScheduleState {
  final String message;

  WeeklyScheduleError({required this.message});

  @override
  List<Object?> get props => [message];
}
