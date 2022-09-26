/// password bridge flow:
///   splash
///     maybeSwitchToPassword()
///     go to login
///       login - onSuccess
///         updatePasswordsToSecureStorage()
///
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;

/// moves hashed passwords to secure storage
Future<void> updatePasswordsToSecureStorage() async {
  var records = <Password>[];
  for (var password in pros.passwords.records) {
    if (password.saltedHash != '') {
      records.add(Password.from(password, saltedHash: ''));
      //resalt?
      await SecureStorage.writeSecret(Secret(
          passwordId: password.id,
          secret: password.saltedHash,
          secretType: SecretType.saltedHashedPassword));
    }
  }
  await pros.passwords.saveAll(records);
}

/// on update they will be by default set to native auth, but if they have
/// passwords they should be switched back to password auth.
Future<void> maybeSwitchToPassword() async {
  final currentPasswordRecord = pros.passwords.current;
  if (currentPasswordRecord != null && currentPasswordRecord.saltedHash != '') {
    await services.authentication
        .setMethod(method: AuthMethod.moontreePassword);
  }
}

Future<String> getLatestSaltedHashedPassword() async =>
    await SecureStorage.read(
        SecureStorage.passwordIdKey(pros.passwords.maxPasswordId ?? 0)) ??
    '';
