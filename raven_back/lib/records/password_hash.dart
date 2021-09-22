import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '_type_id.dart';
part 'password_hash.g.dart';

@HiveType(typeId: TypeId.PasswordHash)
class PasswordHash with EquatableMixin {
  @HiveField(0)
  int passwordId;

  @HiveField(1)
  String saltedHash;

  PasswordHash({
    required this.passwordId,
    required this.saltedHash,
  });

  @override
  List<Object> get props => [passwordId, saltedHash];

  @override
  String toString() => 'PasswordHash(${passwordId.toString()}, $saltedHash)';
}
