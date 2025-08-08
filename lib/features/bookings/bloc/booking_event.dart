import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchBookings extends BookingEvent {
  final int page;
  final String status;

  FetchBookings({this.page = 1, this.status = "All"});

  @override
  List<Object?> get props => [page, status];
}
