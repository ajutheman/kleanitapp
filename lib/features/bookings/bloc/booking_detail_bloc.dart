import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kleanitapp/features/bookings/repo/booking_repository.dart';

import 'booking_detail_event.dart';
import 'booking_detail_state.dart';

class BookingDetailBloc extends Bloc<BookingDetailEvent, BookingDetailState> {
  final BookingRepository repository;

  BookingDetailBloc(this.repository) : super(BookingDetailInitial()) {
    on<FetchBookingDetail>((event, emit) async {
      emit(BookingDetailLoading());
      try {
        final booking = await repository.getOrderDetails(event.encryptedOrderId);
        emit(BookingDetailLoaded(booking));
      } catch (e) {
        emit(BookingDetailError(e.toString()));
      }
    });
    on<CancelOrder>((event, emit) async {
      emit(CancelOrderLoading());
      try {
        await repository.cancelOrder(event.orderId, event.reason);
        emit(CancelOrderSuccess());
      } catch (e) {
        emit(CancelOrderFailure(e.toString()));
      }
    });
  }
}
