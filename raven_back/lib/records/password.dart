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

  factory Password.fromPassword({
    required int id,
    required String password,
  }) {
    return Password(id: id, saltedHash: getSalt(id));
  }

  @override
  List<Object> get props => [id, saltedHash];

  @override
  String toString() => 'Password($id, $saltedHash)';

  String get salt => 'salt$id';

  static String getSalt(int id) => 'salt$id';

  static String passwordKey(int id) => id.toString();
}
