import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/booking_repository.dart';
import 'weekly_schedule_event.dart';
import 'weekly_schedule_state.dart';

class WeeklyScheduleBloc extends Bloc<WeeklyScheduleEvent, WeeklyScheduleState> {
  final BookingRepository bookingRepository;

  WeeklyScheduleBloc({required this.bookingRepository}) : super(WeeklyScheduleInitial()) {
    on<FetchWeeklySchedule>(_onFetchSchedule);
    on<UpdateWeeklySchedule>(_onUpdateSchedule);
  }

  Future<void> _onFetchSchedule(FetchWeeklySchedule event, Emitter<WeeklyScheduleState> emit) async {
    emit(WeeklyScheduleLoading());
    try {
      final schedule = await bookingRepository.fetchScheduleDays(event.orderId);
      emit(WeeklyScheduleLoaded(schedule: schedule));
    } catch (e) {
      emit(WeeklyScheduleError(message: e.toString()));
    }
  }

  Future<void> _onUpdateSchedule(UpdateWeeklySchedule event, Emitter<WeeklyScheduleState> emit) async {
    emit(WeeklyScheduleLoading());
    try {
      await bookingRepository.updateSchedule(event.id, event.days);
      emit(WeeklyScheduleSuccess());
    } catch (e) {
      emit(WeeklyScheduleError(message: e.toString()));
    }
  }
}
