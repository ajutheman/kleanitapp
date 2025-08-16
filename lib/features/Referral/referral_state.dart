import 'package:equatable/equatable.dart';
import 'package:kleanitapp/features/Referral/Appreferal_advertisement.dart';

abstract class ReferalAdvertisementState extends Equatable {
  const ReferalAdvertisementState();

  @override
  List<Object> get props => [];
}

class ReferalAdvertisementInitial extends ReferalAdvertisementState {}

class ReferalAdvertisementLoading extends ReferalAdvertisementState {}

class ReferalAdvertisementLoaded extends ReferalAdvertisementState {
  final List<AppReferalAdvertisement> referalAdvertisements;

  const ReferalAdvertisementLoaded(this.referalAdvertisements);

  @override
  List<Object> get props => [referalAdvertisements];
}

class ReferalAdvertisementError extends ReferalAdvertisementState {
  final String error;

  const ReferalAdvertisementError(this.error);

  @override
  List<Object> get props => [error];
}
