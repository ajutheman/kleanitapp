import 'package:equatable/equatable.dart';

import '../model/booking.dart';

abstract class BookingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<BookingModel> bookings;
  final int currentPage;
  final int totalPages;

  BookingLoaded({required this.bookings, required this.currentPage, required this.totalPages});

  @override
  List<Object?> get props => [bookings, currentPage, totalPages];
}

class BookingError extends BookingState {
  final String message;

  BookingError(this.message);

  @override
  List<Object?> get props => [message];
}
