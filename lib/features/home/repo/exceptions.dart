class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}

class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
}
