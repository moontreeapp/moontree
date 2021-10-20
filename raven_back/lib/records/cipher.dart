/// in memory only record so we don't need hive
import 'package:equatable/equatable.dart';
import 'package:raven/raven.dart';
import 'package:raven/records/cipher_type.dart';
import 'package:raven/utils/enum.dart';

class Cipher with EquatableMixin {
  final CipherType cipherType;
  final int? passwordId;
  final CipherBase cipher;

  Cipher({required this.cipher, required this.cipherType, this.passwordId});

  @override
  List<Object?> get props => [cipherType, passwordId, cipher];

  @override
  String toString() => toMap.toString();

  Map<String, dynamic> get toMap => {
        'CipherType': describeEnum(cipherType),
        'PasswordId': passwordId.toString(),
        'Cipher': cipher.toString(),
      };

  String get cipherId => '${describeEnum(cipherType)}:$passwordId';

  CipherUpdate get cipherUpdate =>
      CipherUpdate(cipherType, passwordId: passwordId);

  String get cipherTypeString => describeEnum(cipherType);
}
