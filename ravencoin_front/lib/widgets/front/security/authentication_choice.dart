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
  AuthMethod? authenticationMethodChoice = AuthMethod.moontreePassword;
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
        //Text(
        //  'Setting a strong password only you know offers the highest level of security for your wallets. You also have the choice to use nativeSecurity authentication if you prefer.\n\nBefore you change your authentication method you should backup your wallets by writing down each of their passphrases on paper. \n\nAfter changing your preference your wallets must be reencrypted, so DO NOT close the app until the re-encryption process has finished.',
        //  style: Theme.of(context).textTheme.bodyText2,
        //),
        SizedBox(height: 16),
        RadioListTile<AuthMethod>(
            title: const Text('Moontree Only Password'),
            value: AuthMethod.moontreePassword,
            groupValue: authenticationMethodChoice,
            onChanged: (AuthMethod? value) async {
              setState(() => authenticationMethodChoice = value);
              //canceled = false;
              //await components.message.giveChoices(
              //  context,
              //  title: 'Set Password',
              //  content:
              //      "In order to complete the change you'll need to set a password.\n\nPress ok to continue...",
              //  behaviors: {
              //    'cancel': () {
              //      setState(() {
              //        authenticationMethodChoice = AuthMethod.nativeSecurity;
              //        canceled = true;
              //      });
              //      Navigator.of(context).pop();
              //    },
              //    'ok': () {
              //      Navigator.of(context).pop();
              //    },
              //  },
              //);
              //if (!canceled) {
              streams.app.verify.add(false); // always require auth
              Navigator.of(components.navigator.routeContext!).pushNamed(
                '/security/password/change',
                arguments: {
                  'Verification.ButtonLabel': 'Continue',
                  'then': () async {
                    await services.authentication.setMethod(method: value!);
                  },
                  'then.then': () async {
                    streams.app.snack.add(Snack(
                        message: 'Successfully Updated Authentication Method'));
                  },
                },
              );
              setState(() {
                if (pros.settings.authMethodIsNativeSecurity) {
                  authenticationMethodChoice = AuthMethod.nativeSecurity;
                }
              });
              //}
            }),
        RadioListTile<AuthMethod>(
            title: const Text('Native Device Security'),
            value: AuthMethod.nativeSecurity,
            groupValue: authenticationMethodChoice,
            onChanged: (AuthMethod? value) async {
              Future<void> onSuccess() async {
                Navigator.pop(components.navigator.routeContext!);
                final localAuthApi = LocalAuthApi();
                final validate = await localAuthApi.authenticate();
                if (validate) {
                  setState(() {
                    authenticationMethodChoice = AuthMethod.nativeSecurity;
                  });
                  components.loading.screen(
                      message: 'Setting Authentication Method',
                      staticImage: true,
                      returnHome: false,
                      playCount: 1);
                  await services.authentication.setMethod(method: value!);
                  await services.authentication.setPassword(
                    password: await SecureStorage.authenticationKey,
                    salt: await SecureStorage.authenticationKey,
                    message: 'Successfully Updated Authentication Method',
                    saveSecret: saveSecret,
                  );
                } else {
                  if (localAuthApi.reason == AuthenticationResult.error) {
                    setState(() {
                      setState(() => authenticationMethodChoice =
                          AuthMethod.moontreePassword);
                    });
                    streams.app.snack.add(Snack(
                      message:
                          'Failed. To use Native Security authentication, set it up a pin in the phone settings.',
                    ));
                  } else if (localAuthApi.reason ==
                      AuthenticationResult.failure) {
                    setState(() => authenticationMethodChoice =
                        AuthMethod.moontreePassword);
                    streams.app.snack.add(Snack(
                      message:
                          'Unable to authenticate; setting login method to password.',
                    ));
                  }
                }
              }

              setState(() => authenticationMethodChoice = value);

              streams.app.verify.add(false); // always require auth
              if (services.password.askCondition) {
                /// you might think we'd ask for their password here, then ask for
                /// native authentication, decrypting the wallets with their
                /// password the only reason we don't need to us that we save the
                /// cipher so we can just use that. however, we need to verify
                /// they really can access it so, we must ask for existing login
                //await components.message.giveChoices(
                //  components.navigator.routeContext!,
                //  title: 'Authenticate to Change Setting',
                //  content:
                //      'To complete the change you must first authenticate with your current authentication method.',
                //  behaviors: {
                //    'CANCEL': () {
                //      Navigator.pop(components.navigator.routeContext!);
                //      setState(() {
                //        authenticationMethodChoice =
                //            AuthMethod.moontreePassword;
                //        canceled = true;
                //      });
                //    },
                //    'OK': () async {
                //Navigator.pop(components.navigator.routeContext!);
                await Navigator.pushNamed(
                  components.navigator.routeContext!,
                  '/security/verification',
                  arguments: {
                    'buttonLabel': 'Continue',
                    'onSuccess': () async {
                      await onSuccess();
                    }
                  },
                );
                setState(() {
                  if (!pros.settings.authMethodIsNativeSecurity) {
                    authenticationMethodChoice = AuthMethod.moontreePassword;
                  }
                });
                //    }
                //  },
                //);
              } else {
                await onSuccess();
              }
            }),
      ],
    );
  }
}
