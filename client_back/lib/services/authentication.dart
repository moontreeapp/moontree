import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';

class AuthenticationService {
  bool get methodIsNative => pros.settings.authMethodIsNativeSecurity;
  bool get methodIsPassword => !pros.settings.authMethodIsNativeSecurity;
  AuthMethod? get method => pros.settings.authMethod;

  Future<void> setMethod({
    required AuthMethod? method,
  }) async =>
      await pros.settings
          .save(Setting(name: SettingName.auth_method, value: method));

  Future<void> setPassword({
    required String password,
    required String salt,
    required Future<void> Function(Secret secret) saveSecret,
    String? message,
  }) async {
    await services.password.create.save(password, salt, saveSecret);
    final CipherBase cipher = services.cipher.updatePassword(
      altPassword: password,
      altSalt: salt,
    );
    await services.cipher.updateWallets(cipher: cipher, saveSecret: saveSecret);
    await services.cipher.cleanupCiphers();
    if (message != null && message != '') {
      streams.app.snack.add(Snack(message: message));
    }
  }
}
