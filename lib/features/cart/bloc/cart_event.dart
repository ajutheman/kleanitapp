import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchCartList extends CartEvent {}

class AddToCart extends CartEvent {
  final int thirdCategoryId;
  final int employeeCount;
  final String type;
  final int subscriptionFrequency;
  final bool isDirectBooking;

  AddToCart({
    required this.thirdCategoryId,
    required this.employeeCount,
    required this.type,
    required this.subscriptionFrequency,
    this.isDirectBooking = false,
  });
}

class UpdateCart extends CartEvent {
  final int cartId;
  final int thirdCategoryId;
  final int employeeCount;
  final String type;
  final int subscriptionFrequency;

  UpdateCart({
    required this.cartId,
    required this.thirdCategoryId,
    required this.employeeCount,
    required this.type,
    required this.subscriptionFrequency,
  });
}

class DeleteCartItem extends CartEvent {
  final String cartId;
  DeleteCartItem({required this.cartId});
}
