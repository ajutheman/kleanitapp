abstract class CouponEvent {}

class ValidateCoupon extends CouponEvent {
  final String couponCode;

  ValidateCoupon({required this.couponCode});
}

class ClearCoupon extends CouponEvent {}
