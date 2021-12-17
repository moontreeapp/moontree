import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven_back/records/cipher_type.dart';
import 'package:raven_back/extensions/object.dart';

import '_type_id.dart';

part 'cipher_update.g.dart';

@HiveType(typeId: TypeId.CipherUpdate)
class CipherUpdate with EquatableMixin {
  @HiveField(0)
  final CipherType cipherType;

  @HiveField(1)
  final int? passwordId;

  const CipherUpdate(this.cipherType, {this.passwordId});
  CipherUpdate.fromMap(map)
      : cipherType = stringToCipherTypeMap[map['CipherType']]!,
        passwordId =
            map['PasswordId'] == 'null' ? null : int.parse(map['PasswordId']);

  @override
  List<Object?> get props => [cipherType, passwordId];

  @override
  String toString() => toMap.toString();

  String get cipherUpdateId => cipherUpdateKey(cipherType, passwordId);

  static String cipherUpdateKey(CipherType cipherType, int? passwordId) =>
      '${cipherType.enumString}:$passwordId';

  Map<String, dynamic> get toMap => {
        'CipherType': cipherType.enumString,
        'PasswordId': passwordId.toString()
      };

  static Map<String, CipherType> get stringToCipherTypeMap =>
      {for (var value in CipherType.values) value.enumString: value};
}

const CipherUpdate defaultCipherUpdate = CipherUpdate(CipherType.None);
