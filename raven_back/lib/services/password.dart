import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:raven_back/raven_back.dart';

class PasswordService {
  final PasswordValidationService validate = PasswordValidationService();
  final PasswordCreationService create = PasswordCreationService();

  bool get exist => passwords.isEmpty ? false : true;

  /// are any wallets encrypted with something other than no cipher
  bool get required {
    for (var cipherUpdate in services.wallet.getAllCipherUpdates) {
      if (cipherUpdate.cipherType != CipherType.None) return true;
    }
    return false;
  }

  bool interruptedPasswordChange() => {
        for (var cipherUpdate in services.wallet.getAllCipherUpdates)
          if (cipherUpdate.passwordId != passwords.maxPasswordId)
            cipherUpdate.passwordId
      }.isNotEmpty;

  void get broadcastLogin => streams.app.login.sink.add(true);
  void get broadcastLogout => streams.app.login.sink.add(false);
}

class PasswordValidationService {
  String getHash(String password, String salt) => services.password.create
      .hashThis(services.password.create.saltPassword(password, salt));

  bool password(String password) =>
      getHash(password, passwords.primaryIndex.getMostRecent()!.salt) ==
      passwords.primaryIndex.getMostRecent()!.saltedHash;

  bool previousPassword(String password) =>
      getHash(password, passwords.primaryIndex.getPrevious()!.salt) ==
      passwords.primaryIndex.getPrevious()!.saltedHash;

  /// returns the number corresponding to how many passwords ago this was used
  /// null = not found
  /// 0 = current
  /// 1 = previous
  /// "password was used x passwords ago"
  int? previouslyUsed(String password) {
    var m = passwords.maxPasswordId;
    if (m == null) {
      return null;
    }
    var ret;
    for (var pass in passwords.data) {
      if (getHash(password, pass.salt) == pass.saltedHash) {
        ret = m - pass.passwordId;
      }
    }
    return ret;
  }

  bool complexity(String password) => password != '';
  //password.length >= 12 &&
  //[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  //    .any((int i) => password.contains(i.toString()));

  List<String> complexityExplained(String password) => [
        if (password == '') ...['must not be blank']
      ];
  //[
  //  if (password.length < 12) ...['must be at least 12 characters long'],
  //  if ([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  //      .any((int i) => !password.contains(i.toString()))) ...[
  //    'must contain at least one number'
  //  ]
  //];
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

  Future save(String password) async {
    await passwords.save(Password(
        passwordId: (passwords.maxPasswordId ?? -1) + 1,
        saltedHash: password == ''
            ? ''
            : hashThis(saltPassword(password,
                Password.getSalt((passwords.maxPasswordId ?? -1) + 1)))));
  }
}
