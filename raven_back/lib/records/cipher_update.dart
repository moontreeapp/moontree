import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/records/cipher_type.dart';

import '_type_id.dart';

part 'cipher_update.g.dart';

@HiveType(typeId: TypeId.CipherUpdate)
class CipherUpdate with EquatableMixin {
  @HiveField(0)
  CipherType cipherType;
  @HiveField(1)
  int passwordVersion;

  CipherUpdate(this.cipherType, this.passwordVersion);

  @override
  List<Object?> get props => [cipherType, passwordVersion];
}
