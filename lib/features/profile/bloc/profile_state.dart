import 'package:equatable/equatable.dart';

import '../model/Appcustomer_model.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final AppCustomerModel customer;

  ProfileLoaded(this.customer);

  @override
  List<Object?> get props => [customer];
}

class ProfileUpdated extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
