class AppUnauthorizedException implements Exception {
  final String message;

  AppUnauthorizedException(this.message);
}

class AppBadRequestException implements Exception {
  final String message;

  AppBadRequestException(this.message);
}
