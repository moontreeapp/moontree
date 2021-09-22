import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:raven/raven.dart';

class PasswordService {
  final PasswordValidationService validate = PasswordValidationService();
  final PasswordCreationService create = PasswordCreationService();

  bool get usingPassword => passwordHashes.primaryIndex.getMostRecent() != null;

  bool interruptedPasswordChange() =>
      {
        for (var cipherUpdate in services.wallets.getAllCipherUpdates)
          cipherUpdate.passwordVersion
      }.length >
      1;
}

class PasswordValidationService {
  String getHash(String password, String salt) => services.passwords.create
      .hashThis(services.passwords.create.saltPassword(password, salt));

  bool password(String password) =>
      getHash(password, passwordHashes.primaryIndex.getMostRecent()!.salt) ==
      passwordHashes.primaryIndex.getMostRecent()!.saltedHash;

  bool previousPassword(String password) =>
      getHash(password, passwordHashes.primaryIndex.getPrevious()!.salt) ==
      passwordHashes.primaryIndex.getPrevious()!.saltedHash;

  /// returns the number corresponding to how many passwords ago this was used
  /// -1 = not found
  /// 0 = current
  /// 1 = previous
  /// "password was used x passwords ago"
  int previouslyUsed(String password) {
    var m = passwordHashes.maxPasswordID;
    for (var passwordHash in passwordHashes.data) {
      if (getHash(password, passwordHash.salt) == passwordHash.saltedHash) {
        return m - passwordHash.passwordId;
      }
    }
    return -1;
  }
}

class PasswordCreationService {
  String saltPassword(String password, String salt) => '$salt$password';

  String hashThis(String saltedPassword) {
    var bytes = utf8.encode(saltedPassword);
    var digest = sha256.convert(bytes);
    //print('Digest as bytes: ${digest.bytes}');
    //print('Digest as hex string: $digest');
    return digest.toString();
  }

  Future makeSave(String password) async => await passwordHashes.save(Password(
      passwordId: passwordHashes.maxPasswordID + 1,
      saltedHash: hashThis(saltPassword(
          password, Password.getSalt(passwordHashes.maxPasswordID + 1)))));
}
