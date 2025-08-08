import 'package:equatable/equatable.dart';
import '../model/address.dart';

abstract class AddressState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final List<CustomerAddress> addresses;
  AddressLoaded(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

class AddressActionSuccess extends AddressState {}

class AddressError extends AddressState {
  final String message;
  AddressError(this.message);

  @override
  List<Object?> get props => [message];
}
