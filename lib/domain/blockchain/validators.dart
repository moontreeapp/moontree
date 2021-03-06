import 'package:dartz/dartz.dart';
import 'package:moontree/domain/blockchain/values.dart';
import 'package:moontree/domain/core/value_failures.dart';

Either<ValueFailure<Protocols>, Protocols> validateProtocol(
    Protocols protocol) {
  if (protocol == Protocols.unknown) {
    return left(ValueFailure.invalidProtocol(protocol));
  } else {
    return right(protocol);
  }
}
