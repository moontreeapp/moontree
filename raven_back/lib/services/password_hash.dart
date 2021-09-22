import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:raven/raven.dart';

class PasswordHashService {
  bool get usingPassword => passwordHashes.primaryIndex.getMostRecent() != null;

  bool verifyPassword(String password) =>
      hashThis(saltPassword(
          password, passwordHashes.primaryIndex.getMostRecent()!.salt)) ==
      passwordHashes.primaryIndex.getMostRecent()!.saltedHash;

  bool verifyPreviousPassword(String password) =>
      hashThis(saltPassword(
          password, passwordHashes.primaryIndex.getPrevious()!.salt)) ==
      passwordHashes.primaryIndex.getPrevious()!.saltedHash;

  /// returns the number corresponding to how many passwords ago this was used
  /// -1 = not found
  /// 0 = current
  /// 1 = previous
  /// "password was used x passwords ago"
  int verifyUsed(String password) {
    var m = passwordHashes.maxPasswordID;
    for (var passwordHash in passwordHashes.data) {
      if (hashThis(saltPassword(password, passwordHash.salt)) ==
          passwordHash.saltedHash) {
        return m - passwordHash.passwordId;
      }
    }
    return -1;
  }

  String saltPassword(String password, String salt) => '$salt$password';

  String hashThis(String saltedPassword) {
    var bytes = utf8.encode(saltedPassword);
    var digest = sha256.convert(bytes);
    //print('Digest as bytes: ${digest.bytes}');
    //print('Digest as hex string: $digest');
    return digest.toString();
  }

  /// there are wallets on an old password version
  bool interruptedPasswordChange() =>
      {
        for (var cipherUpdate in services.wallets.getAllCipherUpdates)
          cipherUpdate.passwordVersion
      }.length >
      1;
}
