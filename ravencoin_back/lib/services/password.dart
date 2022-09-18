import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';

class PasswordService {
  final PasswordValidationService validate = PasswordValidationService();
  final PasswordLockoutService lockout = PasswordLockoutService();
  final PasswordCreationService create = PasswordCreationService();

  bool get exist => pros.passwords.isEmpty ? false : true;

  /// are any wallets encrypted with something other than no cipher
  bool get required {
    for (var cipherUpdate in services.wallet.getAllCipherUpdates) {
      if (cipherUpdate.cipherType != CipherType.None) return true;
    }
    return false;
  }

  bool get askCondition =>
      required &&
      services.cipher.canAskForPasswordNow &&
      !streams.app.verify.value;

  bool interruptedPasswordChange() => {
        for (var cipherUpdate in services.wallet.getAllCipherUpdates)
          if (cipherUpdate.passwordId != pros.passwords.maxPasswordId)
            cipherUpdate.passwordId
      }.isNotEmpty;
}

class PasswordLockoutService {
  int get timeFromAttempts =>
      min(pow(2, pros.settings.loginAttempts.length) * 125, 1000 * 60 * 60)
          .toInt();

  DateTime get lastFailedAttempt => pros.settings.loginAttempts.isNotEmpty
      ? pros.settings.loginAttempts.last
      : DateTime(DateTime.now().year - 1);

  bool timePast() =>
      DateTime.now().difference(lastFailedAttempt).inMilliseconds >=
      timeFromAttempts;

  Future<bool> handleVerificationAttempt(bool verification) async {
    if (verification) {
      if (pros.settings.loginAttempts.isNotEmpty) {
        streams.app.snack.add(Snack(
          message: pros.settings.loginAttempts.length == 1
              ? 'There was ${pros.settings.loginAttempts.length} unsuccessful login attempt'
              : 'There have been ${pros.settings.loginAttempts.length} unsuccessful login attempts',
        ));
        await pros.settings.resetLoginAttempts();
      }
    } else {
      await pros.settings.incrementLoginAttempts();
    }
    return verification;
  }
}

class PasswordValidationService {
  String getHash(String password, String salt) => services.password.create
      .hashThis(services.password.create.saltPassword(password, salt));

  bool password(String password) =>
      getHash(password, pros.passwords.primaryIndex.getMostRecent()!.salt) ==
      pros.passwords.primaryIndex.getMostRecent()!.saltedHash;

  /// unused
  bool previousPassword(String password) =>
      getHash(password, pros.passwords.primaryIndex.getPrevious()!.salt) ==
      pros.passwords.primaryIndex.getPrevious()!.saltedHash;

  /// unused
  /// returns the number corresponding to how many passwords ago this was used
  /// null = not found
  /// 0 = current
  /// 1 = previous
  /// "password was used x passwords ago"
  int? previouslyUsed(String password) {
    var m = pros.passwords.maxPasswordId;
    if (m == null) {
      return null;
    }
    var ret;
    for (var pass in pros.passwords.records) {
      if (getHash(password, pass.salt) == pass.saltedHash) {
        ret = m - pass.id;
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

  Future save(String password, String salt) async {
    await pros.passwords.save(Password(
        id: (pros.passwords.maxPasswordId ?? -1) + 1,
        saltedHash: password == ''
            ? ''
            : hashThis(saltPassword(
                password,
                salt, //Password.getSalt((pros.passwords.maxPasswordId ?? -1) + 1),
              ))));
  }
}
