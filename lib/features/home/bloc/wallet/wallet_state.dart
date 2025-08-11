part of 'wallet_bloc.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final double balance;

  WalletLoaded(this.balance);
}

class WalletError extends WalletState {
  final String message;

  WalletError(this.message);
}
