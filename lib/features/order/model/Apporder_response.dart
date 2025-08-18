class AppOrderResponse {
  final String message;
  final OrderDetail order;
  final StripePaymentIntent? stripePaymentIntent;

  AppOrderResponse({required this.message, required this.order, required this.stripePaymentIntent});

  factory AppOrderResponse.fromJson(Map<String, dynamic> json) => AppOrderResponse(
    message: json['message'],
    order: OrderDetail.fromJson(json['order']),
    stripePaymentIntent: json['stripe_payment_intent'] != null ? StripePaymentIntent.fromJson(json['stripe_payment_intent']) : null,
  );
}

class OrderDetail {
  final String id;
  final String orderNumber;
  final num total;
  final String paymentStatus;
  final bool hasSubscription;

  OrderDetail({required this.id, required this.orderNumber, required this.total, required this.paymentStatus, required this.hasSubscription});

  factory OrderDetail.fromJson(Map<String, dynamic> json) =>
      OrderDetail(id: json['id'], orderNumber: json['order_number'], total: json['total'], paymentStatus: json['payment_status'], hasSubscription: json['has_subscription']);
}

class StripePaymentIntent {
  final String id;
  final String clientSecret;

  StripePaymentIntent({required this.id, required this.clientSecret});

  factory StripePaymentIntent.fromJson(Map<String, dynamic> json) => StripePaymentIntent(id: json['id'], clientSecret: json['client_secret']);
}
