import 'package:equatable/equatable.dart';

import '../model/Appcart.dart';

abstract class CartState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartActionLoading extends CartState {}

class CartLoaded extends CartState {
  final List<AppCart> cartItems;

  CartLoaded({required this.cartItems});

  @override
  List<Object?> get props => [cartItems];
}

class CartActionSuccess extends CartState {
  CartActionSuccess();
}

class CartAddActionSuccess extends CartState {
  final int cartThirdId;
  final bool isDirectBooking;

  CartAddActionSuccess({required this.cartThirdId, required this.isDirectBooking});
}

class CartError extends CartState {
  final String message;

  CartError({required this.message});

  @override
  List<Object?> get props => [message];
}
