import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../respository/token_repository.dart';
import 'token_event.dart';
import 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final TokenRepository repository;

  TokenBloc({required this.repository}) : super(TokenInitial()) {
    on<UpdateToken>(_onRefreshTokenRequested);
  }

  Future<void> _onRefreshTokenRequested(UpdateToken event, Emitter<TokenState> emit) async {
    emit(TokenRefreshing());
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final result = await repository.updateToken(fcmToken: token);
        emit(TokenRefreshed());
      } else {
        emit(TokenRefreshFailed("Token not found"));
      }
    } catch (e) {
      emit(TokenRefreshFailed(e.toString()));
    }
  }
}
