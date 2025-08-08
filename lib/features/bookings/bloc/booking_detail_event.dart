import 'package:equatable/equatable.dart';

abstract class BookingDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchBookingDetail extends BookingDetailEvent {
  final String encryptedOrderId;

  FetchBookingDetail(this.encryptedOrderId);

  @override
  List<Object?> get props => [encryptedOrderId];
}

class CancelOrder extends BookingDetailEvent {
  final String orderId;
  final String reason;

  CancelOrder({required this.orderId, required this.reason});

  @override
  List<Object?> get props => [orderId];
}
