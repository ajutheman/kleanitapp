import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kleanitapp/features/Referral/referal_advertisement_repository.dart';
import 'package:kleanitapp/features/Referral/referral_event.dart';
import 'package:kleanitapp/features/Referral/referral_state.dart';

class ReferalAdvertisementBloc extends Bloc<ReferalAdvertisementEvent, ReferalAdvertisementState> {
  final ReferalAdvertisementRepository repository;
  final String token;

  ReferalAdvertisementBloc({required this.repository, required this.token}) : super(ReferalAdvertisementInitial()) {
    on<LoadReferalAdvertisements>((event, emit) async {
      emit(ReferalAdvertisementLoading());
      try {
        final referals = await repository.fetchReferalAdvertisements(token);
        emit(ReferalAdvertisementLoaded(referals));
      } catch (e) {
        emit(ReferalAdvertisementError(e.toString()));
      }
    });
  }
}
