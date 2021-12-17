import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '_type_id.dart';
part 'password.g.dart';

@HiveType(typeId: TypeId.Password)
class Password with EquatableMixin {
  @HiveField(0)
  int passwordId;

  @HiveField(1)
  String saltedHash;

  Password({
    required this.passwordId,
    required this.saltedHash,
  });

  factory Password.fromPassword({
    required int passwordId,
    required String password,
  }) {
    return Password(passwordId: passwordId, saltedHash: getSalt(passwordId));
  }

  @override
  List<Object> get props => [passwordId, saltedHash];

  @override
  String toString() => 'Password($passwordId, $saltedHash)';

  String get salt => 'salt$passwordId';

  static String getSalt(int passwordId) => 'salt$passwordId';

  static String passwordKey(int passwordId) => passwordId.toString();
}
