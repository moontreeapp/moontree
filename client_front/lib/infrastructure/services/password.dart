/// password bridge flow:
///   splash
///     maybeSwitchToPassword()
///     go to login
///       login - onSuccess
///         updatePasswordsToSecureStorage()
///
import 'package:client_back/client_back.dart';
import 'package:client_front/infrastructure/services/storage.dart'
    show SecureStorage;

/// moves hashed passwords to secure storage
Future<void> updatePasswordsToSecureStorage() async {
  final List<Password> records = <Password>[];
  for (final Password password in pros.passwords.records) {
    if (password.saltedHash != 'deprecated') {
      records.add(Password.from(password, saltedHash: 'deprecated'));
      final String? read =
          await SecureStorage.read(SecureStorage.passwordIdKey(password.id));
      // only update historic passwords here:
      if (read == null) {
        await SecureStorage.writeSecret(Secret(
            passwordId: password.id,
            secret: password.saltedHash,
            secretType: SecretType.saltedHashedPassword));
      }
    }
  }
  await pros.passwords.saveAll(records);
}

/// on update they will be by default set to native auth, but if they have
/// passwords they should be switched back to password auth.
Future<void> maybeSwitchToPassword() async {
  final Password? currentPasswordRecord = pros.passwords.current;
  if (currentPasswordRecord != null &&
      currentPasswordRecord.saltedHash != 'deprecated') {
    await services.authentication
        .setMethod(method: AuthMethod.moontreePassword);
  }
}

Future<String> getLatestSaltedHashedPassword() async =>
    await SecureStorage.read(
        SecureStorage.passwordIdKey(pros.passwords.maxPasswordId ?? 0)) ??
    '';

Future<String> getPreviousSaltedHashedPassword() async =>
    await SecureStorage.read(
        SecureStorage.passwordIdKey((pros.passwords.maxPasswordId ?? 1) - 1)) ??
    '';
