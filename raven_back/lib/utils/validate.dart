import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../raven.dart';

bool verifyPassword(String password) =>
    hashThis(saltPassword(password)) ==
    passwordHashes.primaryIndex.getMostRecent()!.saltedHash;

bool verifyPreviousPassword(String password) =>
    hashThis(saltPassword(password)) ==
    passwordHashes.primaryIndex.getPrevious()!.saltedHash;

/// returns the number corresponding to how many passwords ago this was used
/// -1 = not found
/// 0 = current
/// 1 = previous
/// "password was used x passwords ago"
int verifyUsed(String password) {
  var x = 0;
  var hashed = hashThis(saltPassword(password));
  for (var i = passwordHashes.maxPasswordID(); i >= 0; i--) {
    if (hashed == passwordHashes.primaryIndex.getOne(i)!.saltedHash) {
      return x;
    }
    x = x + 1;
  }
  return -1;
}

/// how is the salt chosen? TODO:
/// the problem is salts should be secret, but we have no server... get from OS?
String getSalt() => 'salt';

String saltPassword(String password) => '${getSalt()}$password';

String hashThis(String saltedPassword) {
  var bytes = utf8.encode(saltedPassword);
  var digest = sha256.convert(bytes);
  print('Digest as bytes: ${digest.bytes}');
  print('Digest as hex string: $digest');
  return digest.toString();
}

/// there are wallets on an old password version
bool interruptedPasswordChange() =>
    {
      for (var cipherUpdate in services.wallets.getAllCipherUpdates)
        cipherUpdate.passwordVersion
    }.length >
    1;
