import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/auth.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:ravencoin_front/services/wallet.dart';
import 'package:ravencoin_front/widgets/front/security/password.dart';

class AuthenticationMethodChoice extends StatefulWidget {
  final dynamic data;
  const AuthenticationMethodChoice({this.data}) : super();

  @override
  _AuthenticationMethodChoice createState() => _AuthenticationMethodChoice();
}

class _AuthenticationMethodChoice extends State<AuthenticationMethodChoice> {
  AuthMethod? authenticationMethodChoice = AuthMethod.password;
  bool canceled = false;

  @override
  void initState() {
    super.initState();
    authenticationMethodChoice = pros.settings.authMethod;
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
          'Setting a strong password only you know offers the highest level of security for your wallets. You also have the choice to use biometric authentication if you prefer.\n\nBefore you change your authentication method you should backup your wallets by writing down each of their passphrases on paper. \n\nAfter changing your preference your wallets must be reencrypted, so DO NOT close the app until the re-encryption process has finished.',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        SizedBox(height: 16),
        RadioListTile<AuthMethod>(
            title: const Text('Password (most secure)'),
            value: AuthMethod.password,
            groupValue: authenticationMethodChoice,
            onChanged: (AuthMethod? value) async {
              setState(() => authenticationMethodChoice = value);
              await components.message.giveChoices(
                context,
                title: 'Set Password',
                content:
                    "In order to complete the change you'll need to set a password.\n\nPress ok to continue...",
                //child: ChangePasswordWidget(),
                behaviors: {
                  'cancel': () {
                    setState(() {
                      authenticationMethodChoice = AuthMethod.biometric;
                      canceled = true;
                    });
                    Navigator.of(context).pop();
                  },
                  'ok': () {
                    Navigator.of(context).pop();
                  },
                },
              );
              if (!canceled) {
                //await services.authentication.setPassword(
                //  password: await SecureStorage.authenticationKey,
                //  salt: await SecureStorage.authenticationKey,
                //  saveSecret: saveSecret,
                //);
                streams.app.verify.add(true);
                Navigator.of(components.navigator.routeContext!)
                    .pushNamed('/security/password/change', arguments: {
                  'then': () async {
                    await services.authentication.setMethod(method: value!);
                  },
                  'then.then': () async {
                    streams.app.snack.add(Snack(
                        message: 'Successfully Updated Authentication Method'));
                  },
                });
                canceled = false;
              }
              //components.loading.screen(
              //    message: 'Re-encrypting Wallets',
              //    staticImage: true,
              //    returnHome: true,
              //    playCount: 3);
            }),
        RadioListTile<AuthMethod>(
            title: const Text('Biometric'),
            value: AuthMethod.biometric,
            groupValue: authenticationMethodChoice,
            onChanged: (AuthMethod? value) async {
              setState(() => authenticationMethodChoice = value);
              final localAuthApi = LocalAuthApi();
              final validate = await localAuthApi.authenticate();
              if (validate) {
                await services.authentication.setMethod(method: value!);
                await services.authentication.setPassword(
                  password: await SecureStorage.authenticationKey,
                  salt: await SecureStorage.authenticationKey,
                  message: 'Successfully Updated Authentication Method',
                  saveSecret: saveSecret,
                );
                //components.loading.screen(
                //    message: 'Re-encrypting Wallets',
                //    staticImage: true,
                //    returnHome: true,
                //    playCount: 3);
              } else {
                if (localAuthApi.reason == AuthenticationResult.error) {
                  setState(() {
                    setState(
                        () => authenticationMethodChoice = AuthMethod.password);
                  });
                  streams.app.snack.add(Snack(
                    message:
                        'Failed. To use biometric authentication, set it up a pin in the phone settings.',
                  ));
                } else if (localAuthApi.reason ==
                    AuthenticationResult.failure) {
                  setState(
                      () => authenticationMethodChoice = AuthMethod.password);
                  streams.app.snack.add(Snack(
                    message:
                        'Unable to authenticate; setting login method to password.',
                  ));
                }
              }
            }),
      ],
    );
  }
}
