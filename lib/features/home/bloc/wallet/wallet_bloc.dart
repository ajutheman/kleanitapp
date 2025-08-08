import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repo/wallet_repository.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository repository;

  WalletBloc(this.repository) : super(WalletInitial()) {
    on<LoadWalletBalance>((event, emit) async {
      emit(WalletLoading());
      try {
        final balance = await repository.fetchWalletBalance();
        emit(WalletLoaded(balance));
      } catch (e) {
        emit(WalletError("Failed to load balance"));
      }
    });
  }
}
