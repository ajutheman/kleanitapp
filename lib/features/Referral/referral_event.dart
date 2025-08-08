import 'package:equatable/equatable.dart';

abstract class ReferalAdvertisementEvent extends Equatable {
  const ReferalAdvertisementEvent();

  @override
  List<Object> get props => [];
}

class LoadReferalAdvertisements extends ReferalAdvertisementEvent {}
