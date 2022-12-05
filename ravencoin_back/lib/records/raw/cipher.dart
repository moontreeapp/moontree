/// in memory only record so we don't need hive
import 'package:equatable/equatable.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class Cipher with EquatableMixin {
  Cipher({required this.cipher, required this.cipherType, this.passwordId});

  final CipherType cipherType;
  final int? passwordId;
  final CipherBase cipher;

  @override
  List<Object?> get props => <Object?>[cipherType, passwordId, cipher];

  @override
  String toString() => toMap.toString();

  Map<String, dynamic> get toMap => {
        'CipherType': cipherType.name,
        'PasswordId': passwordId.toString(),
        'Cipher': cipher.toString(),
      };

  CipherUpdate get cipherUpdate =>
      CipherUpdate(cipherType, passwordId: passwordId);

  String get cipherTypeString => cipherType.name;

  String get id => Cipher.cipherKey(cipherType, passwordId);

  static String cipherKey(CipherType cipherType, int? passwordId) =>
      CipherUpdate.cipherUpdateKey(cipherType, passwordId);
}
