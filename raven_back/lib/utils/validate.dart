import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../raven.dart';

/// we need to be able to validate the previous password too
bool verifyPreviousPassword(password) => true;
//    hashThis(saltPassword(password)) == settings.previousHashedSaltedPassword;

/// to validate a password
/// salted hash saved in settings?
/// compare salted hashed password to it.
bool verifyPassword(password) =>
    hashThis(saltPassword(password)) == settings.hashedSaltedPassword;

/// how is the salt chosen? TODO
String getSalt() => 'salt';

String saltPassword(String password) => '${getSalt()}$password';

String hashThis(String saltedPassword) {
  var bytes = utf8.encode(saltedPassword);
  var digest = sha256.convert(bytes);
  print('Digest as bytes: ${digest.bytes}');
  print('Digest as hex string: $digest');
  return digest.toString();
}

//*on startup detect half changed state and ask for old pass saying, "middle of import detected" *
/// there are wallets on an old password version
bool interruptedPasswordChange() =>
    {
      for (var cipherUpdate in services.wallets.getAllCipherUpdates)
        cipherUpdate.passwordVersion
    }.length >
    1;
