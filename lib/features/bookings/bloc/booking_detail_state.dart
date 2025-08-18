import 'package:equatable/equatable.dart';
import 'package:kleanitapp/features/bookings/model/Appbook_detail.dart';

abstract class BookingDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookingDetailInitial extends BookingDetailState {}

class BookingDetailLoading extends BookingDetailState {}

class BookingDetailLoaded extends BookingDetailState {
  final AppBookingDetails booking;

  BookingDetailLoaded(this.booking);
}

class BookingDetailError extends BookingDetailState {
  final String message;

  BookingDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class CancelOrderLoading extends BookingDetailState {}

class CancelOrderSuccess extends BookingDetailState {}

class CancelOrderFailure extends BookingDetailState {
  final String message;

  CancelOrderFailure(this.message);

  @override
  List<Object?> get props => [message];
}
