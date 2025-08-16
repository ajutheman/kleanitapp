import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/Appcart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final AppCartRepository cartRepository;

  CartBloc({required this.cartRepository}) : super(CartInitial()) {
    on<FetchCartList>(_onFetchCartList);
    on<AddToCart>(_onAddToCart);
    on<UpdateCart>(_onUpdateCart);
    on<DeleteCartItem>(_onDeleteCartItem);
  }

  Future<void> _onFetchCartList(FetchCartList event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cartItems = await cartRepository.fetchCartList();
      emit(CartLoaded(cartItems: cartItems));
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    emit(CartActionLoading());
    try {
      int cartThirdId = await cartRepository.addToCart(
        thirdCategoryId: event.thirdCategoryId,
        employeeCount: event.employeeCount,
        type: event.type,
        subscriptionFrequency: event.subscriptionFrequency,
      );
      add(FetchCartList()); // Refresh cart after add
      emit(CartAddActionSuccess(isDirectBooking: event.isDirectBooking, cartThirdId: cartThirdId));
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCart(UpdateCart event, Emitter<CartState> emit) async {
    emit(CartActionLoading());
    try {
      await cartRepository.updateCart(
        cartId: event.cartId,
        thirdCategoryId: event.thirdCategoryId,
        employeeCount: event.employeeCount,
        type: event.type,
        subscriptionFrequency: event.subscriptionFrequency,
      );
      add(FetchCartList()); // Refresh cart after update
      emit(CartActionSuccess());
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCartItem(DeleteCartItem event, Emitter<CartState> emit) async {
    emit(CartActionLoading());
    try {
      await cartRepository.deleteCart(cartId: event.cartId);
      add(FetchCartList()); // Refresh cart after delete
      emit(CartActionSuccess());
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }
}
