abstract class CouponState {}

class CouponInitial extends CouponState {}

class CouponValidationLoading extends CouponState {}

class CouponValidationSuccess extends CouponState {
  final String couponCode;

  CouponValidationSuccess({required this.couponCode});
}

class CouponValidationFailure extends CouponState {
  final String error;

  CouponValidationFailure(this.error);
}
