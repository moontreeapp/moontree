import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';

class AuthenticationService {
  bool get methodIsBiometric => pros.settings.authMethodIsBiometric;
  bool get methodIsPassword => !pros.settings.authMethodIsBiometric;
  AuthMethod get method => pros.settings.authMethod;

  Future<void> setMethod({
    required AuthMethod method,
  }) async =>
      await pros.settings
          .save(Setting(name: SettingName.Auth_Method, value: method));

  Future<void> setPassword({
    required String password,
    required String salt,
    String? message,
  }) async {
    await services.password.create.save(password, salt);
    var cipher =
        services.cipher.updatePassword(altPassword: password, altSalt: salt);
    await services.cipher.updateWallets(cipher: cipher);
    services.cipher.cleanupCiphers();
    if (message != null && message != '') {
      streams.app.snack.add(Snack(message: message));
    }
  }
}
