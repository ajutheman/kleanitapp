import 'package:equatable/equatable.dart';

import '../model/Appcustomer_model.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final AppCustomerModel updatedCustomer;

  UpdateProfile(this.updatedCustomer);

  @override
  List<Object?> get props => [updatedCustomer];
}
