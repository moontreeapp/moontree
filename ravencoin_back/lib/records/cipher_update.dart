import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/records/types/cipher_type.dart';

import '_type_id.dart';

part 'cipher_update.g.dart';

@HiveType(typeId: TypeId.CipherUpdate)
class CipherUpdate with EquatableMixin {
  const CipherUpdate(this.cipherType, {this.passwordId});

  CipherUpdate.fromMap(Map<String, String> map)
      : cipherType = stringToCipherTypeMap[map['CipherType']]!,
        passwordId = map['PasswordId'] == 'null' || map['PasswordId'] == null
            ? null
            : int.parse(map['PasswordId']!);

  @HiveField(0)
  final CipherType cipherType;

  @HiveField(1)
  final int? passwordId;

  @override
  List<Object?> get props => <Object?>[cipherType, passwordId];

  @override
  String toString() => toMap.toString();

  String get cipherUpdateId => cipherUpdateKey(cipherType, passwordId);

  static String cipherUpdateKey(CipherType cipherType, int? passwordId) =>
      '${cipherType.name}:$passwordId';

  Map<String, String> get toMap => <String, String>{
        'CipherType': cipherType.name,
        'PasswordId': passwordId.toString()
      };

  static Map<String, CipherType> get stringToCipherTypeMap =>
      <String, CipherType>{
        for (CipherType value in CipherType.values) value.name: value
      };
}

const CipherUpdate defaultCipherUpdate = CipherUpdate(CipherType.none);
