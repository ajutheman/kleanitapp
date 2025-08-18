import 'package:equatable/equatable.dart';

abstract class SubAdvertisementEvent extends Equatable {
  const SubAdvertisementEvent();

  @override
  List<Object> get props => [];
}

class LoadSubAdvertisements extends SubAdvertisementEvent {}
