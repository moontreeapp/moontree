class CustomException implements Exception {
  final String? _prefix;
  final String? _message;

  CustomException([this._prefix, this._message]);

  @override
  String toString() => [_prefix, _message].whereType<String>().join(': ');
}

class FetchDataException extends CustomException {
  FetchDataException([String? message])
      : super('Error during communication', message);
}

class BadResponseException extends CustomException {
  BadResponseException([String? message]) : super('Invalid response', message);
}

class BadRequestException extends CustomException {
  BadRequestException([String? message]) : super('Invalid request', message);
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([String? message]) : super('Unauthorised', message);
}

class InvalidInputException extends CustomException {
  InvalidInputException([String? message]) : super('Invalid input', message);
}

class InsufficientFunds extends CustomException {
  InsufficientFunds([String? message]) : super('Insufficient funds', message);
}

class CacheEmpty extends CustomException {
  CacheEmpty([String? message]) : super('Cache empty', message);
}

class BalanceMismatch extends CustomException {
  BalanceMismatch([String? message]) : super('Balance mismatch', message);
}

class WalletMissing extends CustomException {
  WalletMissing([String? message]) : super('Wallet missing', message);
}

class AlreadyListening extends CustomException {
  AlreadyListening([String? message]) : super('Already listening', message);
}

class OneOfMultipleMissing extends CustomException {
  OneOfMultipleMissing(
      [String message =
          'this function requires at least one of multiple optional '
              'or named arguments to be supplied.'])
      : super('One of multiple params missing', message);
}
