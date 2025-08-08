import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';
import '../repo/notification_repository.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<FetchNotificationList>(_onFetchNotifications);
  }

  Future<void> _onFetchNotifications(
      FetchNotificationList event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final list = await repository.fetchNotifications();
      emit(NotificationLoaded(notifications: list));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }
}
