import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';

class PasswordService {
  final PasswordValidationService validate = PasswordValidationService();
  final PasswordLockoutService lockout = PasswordLockoutService();
  final PasswordCreationService create = PasswordCreationService();

  bool get exist => pros.passwords.isNotEmpty;

  /// are any wallets encrypted with something other than no cipher
  bool get required {
    for (final CipherUpdate cipherUpdate
        in services.wallet.getAllCipherUpdates) {
      if (cipherUpdate.cipherType != CipherType.none) {
        return true;
      }
    }
    return false;
  }

  bool get askCondition =>
      required &&
      services.cipher.canAskForPasswordNow &&
      !streams.app.auth.verify.value;

  bool interruptedPasswordChange() => <int?>{
        for (CipherUpdate cipherUpdate in services.wallet.getAllCipherUpdates)
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
        streams.app.behavior.snack.add(Snack(
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

  bool password({
    required String password,
    required String salt,
    required String saltedHashedPassword,
  }) =>
      getHash(password, salt) == saltedHashedPassword;

  bool ancientPassword({required String password, required String salt}) =>
      getHash(password, salt) ==
      pros.passwords.primaryIndex.getMostRecent()!.saltedHash;

  /// unused
  bool previousPassword({
    required String password,
    required String salt,
    required String saltedHashedPassword,
  }) =>
      getHash(password, salt) == saltedHashedPassword;

  /// unused
  /// returns the number corresponding to how many passwords ago this was used
  /// null = not found
  /// 0 = current
  /// 1 = previous
  /// "password was used x passwords ago"
  int? previouslyUsed(String password) {
    final int? m = pros.passwords.maxPasswordId;
    if (m == null) {
      return null;
    }
    int? ret;
    for (final Password pass in pros.passwords.records) {
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

  List<String> complexityExplained(String password) => <String>[
        if (password == '') ...<String>['must not be blank']
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
    final List<int> bytes = utf8.encode(saltedPassword);
    final Digest digest = sha256.convert(bytes);
    //print('Digest as bytes: ${digest.bytes}');
    //print('Digest as hex string: $digest');
    return digest.toString();
  }

  Future<void> save(
    String password,
    String salt,
    Future<void> Function(Secret secret) saveSecret,
  ) async {
    final int id = (pros.passwords.maxPasswordId ?? -1) + 1;
    final String saltedHashedPassword = hashThis(saltPassword(
      password,
      salt, //Password.getSalt((pros.passwords.maxPasswordId ?? -1) + 1),
    ));
    await pros.passwords.save(Password(id: id, saltedHash: 'deprecated'));
    await saveSecret(Secret(
        secret: saltedHashedPassword,
        passwordId: id,
        secretType: SecretType.saltedHashedPassword));
  }
}
