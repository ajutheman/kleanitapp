abstract class TokenState {}

class TokenInitial extends TokenState {}

class TokenRefreshing extends TokenState {}

class TokenRefreshed extends TokenState {}

class TokenRefreshFailed extends TokenState {
  final String error;

  TokenRefreshFailed(this.error);
}
