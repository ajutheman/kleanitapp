import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSchedules extends OrderEvent {
  final DateTime date;
  FetchSchedules({required this.date});
}

class CalculateOrder extends OrderEvent {
  final List<String> cartIds;
  final String coupon;
  final int? subscriptionFrequency;

  CalculateOrder({
    required this.cartIds,
    required this.coupon,
    this.subscriptionFrequency,
  });
}

class PlaceOrder extends OrderEvent {
  final List<String> cartIds;
  final String addressId;
  final String scheduleTime;
  final int? subscriptionFeq;
  final String notes;
  final String paymentMethod;
  final int bedrooms;
  final int beds;
  final int sofaBeds;
  final int occupancy;
  final bool petsPresent;
  final bool withLinen;
  final bool withSupplies;
  final String checkInTime;
  final String checkOutTime;
  final String doorAccessCode;
  final DateTime date;
  final String coupon;
  final String typeOfCleaning;
  final String nextGuestCheckInTime;
  final String wifiAccessCode;

  PlaceOrder({
    required this.cartIds,
    required this.addressId,
    required this.scheduleTime,
    required this.subscriptionFeq,
    required this.notes,
    required this.paymentMethod,
    required this.bedrooms,
    required this.beds,
    required this.sofaBeds,
    required this.occupancy,
    required this.petsPresent,
    required this.withLinen,
    required this.withSupplies,
    required this.checkInTime,
    required this.checkOutTime,
    required this.doorAccessCode,
    required this.date,
    required this.coupon,
    required this.typeOfCleaning,
    required this.nextGuestCheckInTime,
    required this.wifiAccessCode,
    required int bathrooms,
  });
}
