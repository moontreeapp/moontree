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
      for (var cipherUpdate in services.wallets.getCurrentCipherUpdates)
        cipherUpdate.passwordVersion
    }.length >
    1;

/// there are wallets on a previous CipherType:
bool interruptedCipherChange() => {
      for (var cipherUpdate in services.wallets.getCurrentCipherUpdates)
        if (cipherUpdate.cipherType != CipherRegistry.latestCipherType)
          cipherUpdate.cipherType
    }.isNotEmpty;

void handleInterruption() {
  if (interruptedPasswordChange()) {
    /// ask for old password, create those ciphers, continue conversion process

  } else if (interruptedCipherChange()) {
    /// use current password to generate previous ciphertype ciphers  (happens naturally?)
    /// and convert old wallets to new ciphertype

  }
}
