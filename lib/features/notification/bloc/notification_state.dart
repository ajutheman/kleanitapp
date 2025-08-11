import 'package:equatable/equatable.dart';

import '../model/notification_model.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;

  NotificationLoaded({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}
