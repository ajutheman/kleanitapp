import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/Appbooking_repository.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final AppBookingRepository repository;

  BookingBloc({required this.repository}) : super(BookingInitial()) {
    on<FetchBookings>((event, emit) async {
      emit(BookingLoading());
      try {
        final result = await repository.fetchBookings(page: event.page, status: event.status);
        emit(BookingLoaded(bookings: result['bookings'], currentPage: result['currentPage'], totalPages: result['totalPages']));
      } catch (e) {
        emit(BookingError(e.toString()));
      }
    });
  }
}
