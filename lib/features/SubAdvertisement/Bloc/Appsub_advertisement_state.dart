import 'package:equatable/equatable.dart';

import '../model/Appsub_advertisement_model.dart';

abstract class SubAdvertisementState extends Equatable {
  const SubAdvertisementState();

  @override
  List<Object> get props => [];
}

class SubAdvertisementInitial extends SubAdvertisementState {}

class SubAdvertisementLoading extends SubAdvertisementState {}

class SubAdvertisementLoaded extends SubAdvertisementState {
  final List<AppSubAdvertisement> subAdvertisements;

  const SubAdvertisementLoaded(this.subAdvertisements);

  @override
  List<Object> get props => [subAdvertisements];
}

class SubAdvertisementError extends SubAdvertisementState {
  final String error;

  const SubAdvertisementError(this.error);

  @override
  List<Object> get props => [error];
}
