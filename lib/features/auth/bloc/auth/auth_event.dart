// lib/logic/blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class GoogleLoginRequested extends AuthEvent {
  final String idToken;
  const GoogleLoginRequested({required this.idToken});
  @override
  List<Object?> get props => [idToken];
}

class OTPLoginRequested extends AuthEvent {
  final String mobile;
  const OTPLoginRequested({required this.mobile});
  @override
  List<Object?> get props => [mobile];
}

class OTPVerificationRequested extends AuthEvent {
  final String mobile;
  final String otp;
  const OTPVerificationRequested({required this.mobile, required this.otp});
  @override
  List<Object?> get props => [mobile, otp];
}
