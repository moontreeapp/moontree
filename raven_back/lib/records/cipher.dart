/// in memory only record so we don't need hive
import 'package:equatable/equatable.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/records/cipher_type.dart';
import 'package:raven_back/extensions/object.dart';

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
        'CipherType': cipherType.enumString,
        'PasswordId': passwordId.toString(),
        'Cipher': cipher.toString(),
      };

  CipherUpdate get cipherUpdate =>
      CipherUpdate(cipherType, passwordId: passwordId);

  String get cipherTypeString => cipherType.enumString;

  String get cipherId => Cipher.cipherKey(cipherType, passwordId);

  static String cipherKey(CipherType cipherType, int? passwordId) =>
      CipherUpdate.cipherUpdateKey(cipherType, passwordId);
}
