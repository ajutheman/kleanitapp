import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repo/order_repository.dart';
import 'coupon_event.dart';
import 'coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final OrderRepository orderRepository;

  CouponBloc({required this.orderRepository}) : super(CouponInitial()) {
    on<ValidateCoupon>(_onValidateCoupon);
    on<ClearCoupon>(_onClearCoupon);
  }

  Future<void> _onValidateCoupon(
      ValidateCoupon event, Emitter<CouponState> emit) async {
    emit(CouponValidationLoading());

    try {
      await orderRepository.validateCoupon(event.couponCode);

      emit(CouponValidationSuccess(
        couponCode: event.couponCode,
      ));
    } on DioException catch (e) {
      emit(CouponValidationFailure(
          e.response?.data['message'].toString() ?? "Invalid coupon"));
    } catch (e) {
      emit(CouponValidationFailure(e.toString()));
    }
  }

  Future<void> _onClearCoupon(
      ClearCoupon event, Emitter<CouponState> emit) async {
    emit(CouponInitial());
  }
}
