import 'package:equatable/equatable.dart';

import '../model/advertisement_model.dart';

// import 'advertisement_model.dart';

abstract class AdvertisementState extends Equatable {
  const AdvertisementState();

  @override
  List<Object> get props => [];
}

class AdvertisementInitial extends AdvertisementState {}

class AdvertisementLoading extends AdvertisementState {}

class AdvertisementLoaded extends AdvertisementState {
  final List<Advertisement> advertisements;

  const AdvertisementLoaded(this.advertisements);

  @override
  List<Object> get props => [advertisements];
}

class AdvertisementError extends AdvertisementState {
  final String error;

  const AdvertisementError(this.error);

  @override
  List<Object> get props => [error];
}
