import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/records/cipher_type.dart';
import 'package:raven/utils/enum.dart';

import '_type_id.dart';

part 'cipher_update.g.dart';

@HiveType(typeId: TypeId.CipherUpdate)
class CipherUpdate with EquatableMixin {
  @HiveField(0)
  CipherType cipherType;

  @HiveField(1)
  int passwordVersion;

  CipherUpdate(this.cipherType, this.passwordVersion);
  CipherUpdate.fromMap(map)
      : cipherType = stringToCipherTypeMap[map['CipherType']]!,
        passwordVersion = int.parse(map['passwordVersion']);

  @override
  List<Object?> get props => [cipherType, passwordVersion];

  static Map<String, CipherType> get stringToCipherTypeMap =>
      {for (var value in CipherType.values) describeEnum(value): value};

  //@override
  //String get toString =>
  //    '${describeEnum(cipherType)}, ${passwordVersion.toString()}';

  Map<String, dynamic> get toMap => {
        'CipherType': describeEnum(cipherType),
        'PasswordVersion': passwordVersion.toString()
      };
}