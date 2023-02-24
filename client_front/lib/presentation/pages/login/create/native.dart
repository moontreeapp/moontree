import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_settings/app_settings.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_back/services/consent.dart' show consentToAgreements;
import 'package:client_front/domain/utils/auth.dart';
import 'package:client_front/domain/utils/login.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/domain/utils/device.dart' show getId;
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/infrastructure/services/auth.dart';
import 'package:client_front/infrastructure/services/storage.dart'
    show SecureStorage;
import 'package:client_front/infrastructure/services/wallet.dart'
    show saveSecret, setupWallets;
import 'package:client_front/infrastructure/services/dev.dart';
import 'package:client_front/application/login/cubit.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/widgets/login/components.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/services/services.dart' show sail;

class LoginCreateNative extends StatefulWidget {
  const LoginCreateNative({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('LoginCreateNative');
  @override
  _LoginCreateNativeState createState() => _LoginCreateNativeState();
}

class _LoginCreateNativeState extends State<LoginCreateNative> {
  Map<String, dynamic> data = <String, dynamic>{};
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  FocusNode unlockFocus = FocusNode();
  bool enabled = true;
  bool failedAttempt = false;
  bool isConsented = false;
  bool consented = false;
  late bool needsConsent;
  final LocalAuthApi localAuthApi = LocalAuthApi();

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.active.listen((bool value) {
      if (value) {
        setState(() {});
      }
    }));
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    needsConsent = data['needsConsent'] as bool? ?? true;
    return FutureBuilder<bool>(
        future: localAuthApi.entirelyReadyToAuthenticate,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return BlocBuilder<LoginCubit, LoginCubitState>(
              builder: (context, state) {
            // todo: move all state into cubit instead of replicating state
            isConsented = state.isConsented;
            return PageStructure(
              children: [
                SizedBox(height: 76.figmaH),
                SizedBox(height: 128.figmaH, child: MoontreeLogo()),
                Container(
                    alignment: Alignment.bottomCenter,
                    height: (16 + 24).figmaH,
                    child: WelcomeMessage()),
                Container(
                    alignment: Alignment.bottomCenter,
                    height: (16 + 24).figmaH,
                    child: Text(
                      "${Platform.isIOS ? 'iOS' : 'Android'} Phone Security",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: AppColors.black),
                    )),
                if (snapshot.hasData && !snapshot.data!)
                  Container(
                      alignment: Alignment.center,
                      height: (8 + 16 + 24).figmaH,
                      child: Text(
                        'Please setup Face, Fingerprints, Pattern, PIN, or Password',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w600),
                      )),
              ],
              firstLowerChildren: <Widget>[
                if (needsConsent) UlaMessage() else const SizedBox(height: 100),
              ],
              secondLowerChildren: <Widget>[
                if (snapshot.hasData)
                  snapshot.data!
                      ? BottomButton(
                          focusNode: unlockFocus,
                          enabled: readyToUnlock(),
                          label:
                              enabled ? 'Create Wallet' : 'Creating Wallet...',
                          onPressed: () async => submit(),
                        )
                      : BottomButton(
                          focusNode: unlockFocus,
                          enabled: readyToUnlock(),
                          label: 'Setup',
                          onPressed: () async => submitSetup(),
                        )
                else
                  const CircularProgressIndicator()
              ],
            );
          });
        });
  }

  Future<void> submitSetup() async {
    if (Platform.isIOS) {
      await AppSettings.openSecuritySettings();
    } else {
      await AppSettings.openSecuritySettings();
      // android only alternative
      //import 'package:open_settings/open_settings.dart';
      //await OpenSettings.openSecuritySetting();
    }
  }

  Future<void> submit() async {
    setState(() => enabled = false);
    streams.app.authenticating.add(true);
    final bool validate = await localAuthApi.authenticate(
        skip: devFlags.contains(DevFlag.skipPin));
    streams.app.authenticating.add(false);
    if (await services.password.lockout.handleVerificationAttempt(validate)) {
      final String key = await SecureStorage.authenticationKey;

      /// actually don't show this, not necessary
      //components.message.giveChoices(context,
      //    title: 'Default Password',
      //    content:
      //        "Moontree has generated a default password for you. If you're ever unable to use your nativeSecurity or pin to login you can use this password instead. Please write it down for your records: $key",
      //    behaviors: {
      //      'ok': () => Navigator.of(context).pop(),
      //    });
      if (!consented) {
        consented = await consentToAgreements(await getId());
      }
      await components.loading.screen(
        message: 'Creating Wallet',
        returnHome: false,
        playCount: 4,
      );
      if (pros.passwords.records.isEmpty) {
        //services.cipher.initCiphers(altPassword: key, altSalt: key);
        await services.authentication.setPassword(
          password: key,
          salt: key,
          saveSecret: saveSecret,
        );
        await setupWallets();
      }
      //await components.message.giveChoices(context,
      //    title: 'Default Password',
      //    content:
      //        "Moontree has generated a default password for you. If you're ever unable to use your nativeSecurity or pin to login you can use this password instead. Please write it down for your records: \n\n$key",
      //    behaviors: {
      //      'ok': () => Navigator.of(context).pop(),
      //    });

      login(context);
    } else {
      if (localAuthApi.reason == AuthenticationResult.error) {
        setState(() {
          enabled = true;
        });
        streams.app.snack.add(Snack(
          message: 'No pin detected; please set a password.',
        ));
        Future<Object?>.microtask(() => sail.to(
            getMethodPathCreate(nativeSecurity: false),
            replaceOverride: true));
      } else if (localAuthApi.reason == AuthenticationResult.failure) {
        setState(() {
          failedAttempt = true;
          enabled = true;
        });
      }
    }
  }

  bool isConnected() =>
      streams.client.connected.value == ConnectionStatus.connected;

  /// nativeSecurity has it's own timeout...
  bool readyToUnlock() =>
      //services.password.lockout.timePast() &&
      enabled && (isConsented || !needsConsent);
}
