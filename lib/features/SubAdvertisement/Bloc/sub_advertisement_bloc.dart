import 'package:flutter_bloc/flutter_bloc.dart';

import '../Repository/sub_advertisement_repository.dart';
import 'sub_advertisement_event.dart';
import 'sub_advertisement_state.dart';

class SubAdvertisementBloc
    extends Bloc<SubAdvertisementEvent, SubAdvertisementState> {
  final SubAdvertisementRepository repository;
  final String token;

  SubAdvertisementBloc({required this.repository, required this.token})
      : super(SubAdvertisementInitial()) {
    on<LoadSubAdvertisements>((event, emit) async {
      emit(SubAdvertisementLoading());
      try {
        final subAds = await repository.fetchSubAdvertisements(token);
        emit(SubAdvertisementLoaded(subAds));
      } catch (e) {
        emit(SubAdvertisementError(e.toString()));
      }
    });
  }
}
