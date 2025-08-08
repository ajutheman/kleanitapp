import 'package:flutter_bloc/flutter_bloc.dart';

import '../Repository/advertisement_repository.dart';
import 'advertisement_event.dart';
import 'advertisement_state.dart';

class AdvertisementBloc extends Bloc<AdvertisementEvent, AdvertisementState> {
  final AdvertisementRepository repository;
  final String token;

  AdvertisementBloc({required this.repository, required this.token})
      : super(AdvertisementInitial()) {
    on<LoadAdvertisements>((event, emit) async {
      emit(AdvertisementLoading());
      try {
        final advertisements = await repository.fetchAdvertisements(token);
        emit(AdvertisementLoaded(advertisements));
      } catch (e) {
        emit(AdvertisementError(e.toString()));
      }
    });
  }
}
