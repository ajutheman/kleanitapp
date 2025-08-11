// home_state.dart
part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeServiceAvailable extends HomeState {
  final String message;
  final Customer? customer;

  const HomeServiceAvailable(this.message, {this.customer});

  @override
  List<Object?> get props => [message, customer];
}

class HomeServiceNotAvailable extends HomeState {
  final String message;
  final Customer? customer;

  const HomeServiceNotAvailable(this.message, {this.customer});

  @override
  List<Object?> get props => [message, customer];
}

class HomeTokenExpired extends HomeState {
  final String message;

  const HomeTokenExpired(this.message);

  @override
  List<Object> get props => [message];
}

class HomeError extends HomeState {
  final String error;

  const HomeError(this.error);

  @override
  List<Object> get props => [error];
}
