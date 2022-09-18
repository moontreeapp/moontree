import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
//import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;

class AuthenticationMethodChoice extends StatefulWidget {
  final dynamic data;
  const AuthenticationMethodChoice({this.data}) : super();

  @override
  _AuthenticationMethodChoice createState() => _AuthenticationMethodChoice();
}

class _AuthenticationMethodChoice extends State<AuthenticationMethodChoice> {
  AuthMethod? authenticationMethodChoice = AuthMethod.password;

  @override
  void initState() {
    super.initState();
    authenticationMethodChoice = pros.settings.authMethodIsBiometric
        ? AuthMethod.password
        : AuthMethod.biometric;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Authentication Method',
            style: Theme.of(context).textTheme.bodyText1),
        Text(
          'Setting a strong password is the most secure way to secure your wallets. You also have the choice to use biometric authentication if you prefer. Before you change your authentication method you should backup your wallets by writing down their passphrases on paper. If you change your preference your wallets must be reencrypted: DO NOT close the app until the process has finished.',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        SizedBox(height: 16),
        RadioListTile<AuthMethod>(
            title: const Text('Password'),
            value: AuthMethod.password,
            groupValue: authenticationMethodChoice,
            onChanged: (AuthMethod? value) async {
              setState(() => authenticationMethodChoice = value);
              await services.authentication.setMethod(method: value!);
              await services.authentication.setPassword(
                password: 'ask for password',
                salt: await SecureStorage.biometricKey,
                message: 'Successfully Updated Authentication Method',
              );
              //components.loading.screen(
              //    message: 'Re-encrypting Wallets',
              //    staticImage: true,
              //    returnHome: true,
              //    playCount: 3);
            }),
        RadioListTile<AuthMethod>(
            title: const Text('Biometric (less secure)'),
            value: AuthMethod.biometric,
            groupValue: authenticationMethodChoice,
            onChanged: (AuthMethod? value) async {
              setState(() => authenticationMethodChoice = value);
              await services.authentication.setMethod(method: value!);
              await services.authentication.setPassword(
                password: await SecureStorage.biometricKey,
                salt: await SecureStorage.biometricKey,
                message: 'Successfully Updated Authentication Method',
              );
              //components.loading.screen(
              //    message: 'Re-encrypting Wallets',
              //    staticImage: true,
              //    returnHome: true,
              //    playCount: 3);
            }),
      ],
    );
  }
}
