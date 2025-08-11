// lib/logic/blocs/auth/auth_state.dart
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  final Map<String, dynamic> customer;

  const AuthSuccess({required this.token, required this.customer});

  @override
  List<Object?> get props => [token, customer];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

/// State when OTP login API call is successful (OTP sent).
class OTPLoginSuccess extends AuthState {
  final String message;
  final String mobile;

  const OTPLoginSuccess({required this.message, required this.mobile});

  @override
  List<Object?> get props => [message, mobile];
}

/// State when OTP verification is successful (login complete).
class OTPVerificationSuccess extends AuthState {
  final String message;
  final String token;
  final int customerId;

  const OTPVerificationSuccess({required this.message, required this.token, required this.customerId});

  @override
  List<Object?> get props => [message, token, customerId];
}
