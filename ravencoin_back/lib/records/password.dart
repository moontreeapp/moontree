import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '_type_id.dart';
part 'password.g.dart';

@HiveType(typeId: TypeId.Password)
class Password with EquatableMixin {
  @HiveField(0)
  int id;

  @HiveField(1)
  String saltedHash;

  Password({
    required this.id,
    required this.saltedHash,
  });

  factory Password.from(Password password, {int? id, String? saltedHash}) =>
      Password(
        id: id ?? password.id,
        saltedHash: saltedHash ?? password.saltedHash,
      );

  @override
  List<Object> get props => [id, saltedHash];

  @override
  String toString() => 'Password($id, $saltedHash)';

  String get salt => 'moontree$id';

  static String getSalt(int id) => 'moontree$id';

  static String passwordKey(int id) => id.toString();
}
