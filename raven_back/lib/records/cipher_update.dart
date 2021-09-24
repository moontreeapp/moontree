import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/records/cipher_type.dart';
import 'package:raven/utils/enum.dart';

import '_type_id.dart';

part 'cipher_update.g.dart';

@HiveType(typeId: TypeId.CipherUpdate)
class CipherUpdate with EquatableMixin {
  @HiveField(0)
  final CipherType cipherType;

  @HiveField(1)
  final int passwordId;

  const CipherUpdate(this.cipherType, this.passwordId);
  CipherUpdate.fromMap(map)
      : cipherType = stringToCipherTypeMap[map['CipherType']]!,
        passwordId = int.parse(map['passwordId']);

  @override
  List<Object?> get props => [cipherType, passwordId];

  @override
  String toString() => toMap.toString();

  Map<String, dynamic> get toMap => {
        'CipherType': describeEnum(cipherType),
        'PasswordId': passwordId.toString()
      };

  static Map<String, CipherType> get stringToCipherTypeMap =>
      {for (var value in CipherType.values) describeEnum(value): value};
}

const CipherUpdate defaultCipherUpdate = CipherUpdate(CipherType.None, 0);
