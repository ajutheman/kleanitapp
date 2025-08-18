import 'package:equatable/equatable.dart';

import '../model/Apporder_calculation.dart';
import '../model/Apporder_response.dart';
import '../model/Apptime_schedule.dart';

abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final AppOrderCalculation orderCalculation;

  OrderLoaded({required this.orderCalculation});

  @override
  List<Object?> get props => [orderCalculation];
}

class OrderError extends OrderState {
  final String message;

  OrderError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OrderPlaced extends OrderState {
  final AppOrderResponse orderResponse;

  OrderPlaced({required this.orderResponse});

  @override
  List<Object?> get props => [orderResponse];
}

class ScheduleLoaded extends OrderState {
  final List<AppTimeSchedule> schedules;

  ScheduleLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}
