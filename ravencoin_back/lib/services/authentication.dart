import 'package:ravencoin_back/ravencoin_back.dart';

class AuthenticationService {
  bool get methodIsBiometric => pros.settings.authMethodIsBiometric;
  bool get methodIsPassword => !pros.settings.authMethodIsBiometric;
  AuthMethod get method =>
      pros.settings.primaryIndex.getOne(SettingName.Auth_Method)!.value;

  Future<void> setMethod({
    required AuthMethod method,
    required String password,
    required String salt,
  }) async {
    // set
    await pros.settings
        .save(Setting(name: SettingName.Auth_Method, value: method));

    // re-encrypt wallets by just saving the key as a password
    streams.password.update.add({
      'password': password,
      'salt': salt,
      'message': 'Successfully Updated Authentication Method',
    });
  }
}
