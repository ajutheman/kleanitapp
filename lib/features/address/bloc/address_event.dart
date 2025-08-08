import 'package:equatable/equatable.dart';
import '../model/address.dart';

abstract class AddressEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAddresses extends AddressEvent {}

class AddAddress extends AddressEvent {
  final Map<String, dynamic> payload;
  AddAddress(this.payload);
}

class DeleteAddress extends AddressEvent {
  final String encryptedId;

  DeleteAddress(this.encryptedId);
}

class UpdateAddress extends AddressEvent {
  final String encryptedId;
  final Map<String, dynamic> payload;
  UpdateAddress({required this.encryptedId, required this.payload});
}
