part of 'cipher.dart';

/// primary key - CipherUpdate

class _IdKey extends Key<Cipher> {
  @override
  String getKey(Cipher cipher) => cipher.id;
}

extension ByCipherUpdateMethodsForCipher on Index<_IdKey, Cipher> {
  Cipher? getOne(CipherType cipherType, int? passwordId) =>
      getByKeyStr(Cipher.cipherKey(cipherType, passwordId)).firstOrNull;
  Cipher? getOneByCipherUpdate(CipherUpdate cipherUpdate) =>
      getByKeyStr(cipherUpdate.cipherUpdateId).firstOrNull;
}

/// byPassword

class _PasswordKey extends Key<Cipher> {
  @override
  String getKey(Cipher cipher) => cipher.passwordId.toString();
}

extension ByPasswordMethodsForCipher on Index<_PasswordKey, Cipher> {
  List<Cipher> getAll(int? passwordId) => getByKeyStr(passwordId.toString());
}

/// byCipherTypeKey

class _CipherTypeKey extends Key<Cipher> {
  @override
  String getKey(Cipher cipher) => cipher.cipherTypeString;
}

extension ByCipherTypeMethodsForCipher on Index<_CipherTypeKey, Cipher> {
  List<Cipher> getAll(CipherType cipherType) => getByKeyStr(cipherType.name);
}
