import 'dart:io';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/auth.dart';
import 'package:client_front/infrastructure/services/dev.dart';
import 'package:client_front/infrastructure/services/storage.dart'
    show SecureStorage;
import 'package:client_front/infrastructure/services/wallet.dart'
    show saveSecret;

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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        //Text('Authentication Method',
        //    style: Theme.of(context).textTheme.bodyText1),
        //Text(
        //  'Setting a strong password only you know offers the highest level of security for your wallets. You also have the choice to use nativeSecurity authentication if you prefer.\n\nBefore you change your authentication method you should backup your wallets by writing down each of their passphrases on paper. \n\nAfter changing your preference your wallets must be reencrypted, so DO NOT close the app until the re-encryption process has finished.',
        //  style: Theme.of(context).textTheme.bodyText2,
        //),
        //SizedBox(height: 16),
        RadioListTile<AuthMethod>(
            title: Text(
              "${Platform.isIOS ? 'iOS' : 'Android'} Phone Security",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            value: AuthMethod.nativeSecurity,
            groupValue: authenticationMethodChoice,
            onChanged: (AuthMethod? value) async {
              Future<void> onSuccess() async {
                final LocalAuthApi localAuthApi = LocalAuthApi();
                streams.app.auth.authenticating.add(true);
                final bool validate = await localAuthApi.authenticate(
                    skip: devFlags.contains(DevFlag.skipPin));
                streams.app.auth.authenticating.add(false);
                if (validate) {
                  if (mounted) {
                    setState(() {
                      authenticationMethodChoice = AuthMethod.nativeSecurity;
                    });
                  }
                  components.loading.screen(
                      message: 'Setting Security',
                      staticImage: true,
                      returnHome: true,
                      playCount: 1);
                  final String key = await SecureStorage.authenticationKey;
                  await services.authentication.setPassword(
                    password: key,
                    salt: key,
                    message: 'Successfully Updated Security',
                    saveSecret: saveSecret,
                  );
                  await services.authentication.setMethod(method: value!);
                } else {
                  if (localAuthApi.reason == AuthenticationResult.error) {
                    setState(() {
                      setState(() => authenticationMethodChoice =
                          AuthMethod.moontreePassword);
                    });
                    streams.app.behavior.snack.add(Snack(
                      message:
                          'Failed. To use Native Security authentication, set it up a pin in the phone settings.',
                    ));
                  } else if (localAuthApi.reason ==
                      AuthenticationResult.failure) {
                    setState(() => authenticationMethodChoice =
                        AuthMethod.moontreePassword);
                    streams.app.behavior.snack.add(Snack(
                      message:
                          'Unable to authenticate; setting login method to password.',
                    ));
                  }
                }
              }

              setState(() => authenticationMethodChoice = value);

              streams.app.auth.verify.add(false); // require auth
              if (services.password.askCondition) {
                // TODO: fix this - complete setup of this security
                //await Navigator.pushNamed(
                //  components.routes.routeContext!,
                //  '/security/security',
                //  arguments: <String, Object>{
                //    'buttonLabel': 'Submit',
                //    'onSuccess': () async {
                //      Navigator.pop(components.routes.routeContext!);
                //      await onSuccess();
                //    }
                //  },
                //);
                if (mounted) {
                  setState(() {
                    if (!pros.settings.authMethodIsNativeSecurity) {
                      authenticationMethodChoice = AuthMethod.moontreePassword;
                    }
                  });
                }
              } else {
                await onSuccess();
              }
            }),
        RadioListTile<AuthMethod>(
            title: Text(
              'Moontree Password',
              style: Theme.of(context).textTheme.bodyText1,
            ),
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
              streams.app.auth.verify.add(false); // always require auth
              // TODO: fix this - complete setup of this security
              //Navigator.of(components.routes.routeContext!).pushNamed(
              //  '/security/password/change',
              //  arguments: <String, Object>{
              //    'verification.ButtonLabel': 'Continue',
              //    'onSuccess.returnHome': true,
              //    'then': () async {
              //      setState(() {
              //        if (pros.settings.authMethodIsNativeSecurity) {
              //          authenticationMethodChoice =
              //              AuthMethod.moontreePassword;
              //        }
              //      });
              //      await services.authentication.setMethod(method: value!);
              //    },
              //    //'then.then': () async {
              //    //  streams.app.behavior.snack
              //    //      .add(Snack(message: 'Successfully Updated Security'));
              //    //},
              //  },
              //);
              setState(() {
                if (pros.settings.authMethodIsNativeSecurity) {
                  authenticationMethodChoice = AuthMethod.nativeSecurity;
                }
              });
              //}
            }),
      ],
    );
  }
}
