class CustomException implements Exception {
  final _prefix;
  final _message;

  CustomException([this._prefix, this._message]);

  @override
  String toString() {
    return '$_prefix$_message';
  }
}

class FetchDataException extends CustomException {
  FetchDataException([String? message])
      : super('Error During Communication: ', message);
}

class BadResponseException extends CustomException {
  BadResponseException([String? message])
      : super('Invalid Response: ', message);
}

class BadRequestException extends CustomException {
  BadRequestException([String? message]) : super('Invalid Request: ', message);
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([String? message]) : super('Unauthorised: ', message);
}

class InvalidInputException extends CustomException {
  InvalidInputException([String? message]) : super('Invalid Input: ', message);
}
