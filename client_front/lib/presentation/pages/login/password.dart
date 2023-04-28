import 'dart:io';
import 'dart:async';
import 'package:client_front/presentation/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_back/services/consent.dart' show consentToAgreements;
import 'package:client_front/domain/utils/login.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/domain/utils/device.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/infrastructure/services/password.dart';
import 'package:client_front/infrastructure/services/services.dart';
import 'package:client_front/infrastructure/services/storage.dart'
    show SecureStorage;
import 'package:client_front/infrastructure/services/wallet.dart'
    show
        populateWalletsWithSensitives,
        updateChain,
        updateEnumLowerCase,
        updateWalletNames,
        updateWalletsToSecureStorage;
import 'package:client_front/application/login/cubit.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_front/presentation/widgets/login/components.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/page.dart';

class LoginPassword extends StatefulWidget {
  const LoginPassword({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('LoginPassword');
  @override
  _LoginPasswordState createState() => _LoginPasswordState();
}

class _LoginPasswordState extends State<LoginPassword> {
  Map<String, dynamic> data = <String, dynamic>{};
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  TextEditingController password = TextEditingController();
  bool passwordVisible = false;
  FocusNode loginFocus = FocusNode();
  FocusNode unlockFocus = FocusNode();
  String? passwordText;
  bool failedAttempt = false;
  bool isConsented = false;
  bool consented = false;
  late bool needsConsent;

  Future<void> finishLoadingDatabase() async {
    if (await HIVE_INIT.isPartiallyLoaded()) {
      await HIVE_INIT.setupDatabase2();
    }
  }

  Future<void> finishLoadingWaiters() async {
    if (await HIVE_INIT.isPartiallyLoaded()) {
      await HIVE_INIT.setupWaiters2();
    }
  }

  Future<bool> get finishedLoading async => HIVE_INIT.isLoaded();

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.active.active.listen((bool value) {
      if (value) {
        setState(() {});
      }
    }));
    finishLoadingDatabase();
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    password.dispose();
    loginFocus.dispose();
    unlockFocus.dispose();
    super.dispose();
  }

  Future<void> bypass() async {
    final String key = await SecureStorage.authenticationKey;
    if (services.password.validate.password(
        password: key,
        salt: key,
        saltedHashedPassword: await getLatestSaltedHashedPassword())) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await initiateLogin(key);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      data = populateData(context, data);
    } catch (e) {
      data = <String, dynamic>{};
    }
    needsConsent = data['needsConsent'] as bool? ?? false;
    bypass();
    final Widget loginField = TextFieldFormatted(
        focusNode: loginFocus,
        autocorrect: false,
        controller: password,
        obscureText: !passwordVisible, // masked controller for immediate?
        textInputAction: TextInputAction.done,
        labelText: 'Password',
        errorText: password.text == '' &&
                pros.settings.loginAttempts.length > 0 &&
                failedAttempt
            ? 'Incorrect Password'
            : null,
        //suffixIcon: IconButton(
        //  icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off,
        //      color: AppColors.black60),
        //  onPressed: () => setState(() {
        //    passwordVisible = !passwordVisible;
        //  }),
        //),
        onChanged: (_) {
          setState(() {});
        },
        onEditingComplete: () {
          FocusScope.of(context).requestFocus(unlockFocus);
          setState(() {});
        });

    return BlocBuilder<LoginCubit, LoginCubitState>(builder: (context, state) {
      isConsented = state.isConsented;
      return PageStructure(
        children: [
          if (screen.app.height >= 640) SizedBox(height: 40.figmaH),
          SizedBox(height: 128.figmaH, child: MoontreeLogo()),
          Container(
              alignment: Alignment.bottomCenter,
              height: (16 + 24).figmaH,
              child: WelcomeMessage()),
          const LockedOutTime(),
          Container(
              alignment: Alignment.center, height: 120, child: loginField),
        ],
        firstLowerChildren: [
          ...needsConsent
              ? <Widget>[
                  UlaMessage(),
                ]
              : <Widget>[const SizedBox(height: 100 - 32)],
        ],
        secondLowerChildren: [
          BottomButton(
              enabled: password.text != '' &&
                  services.password.lockout.timePast() &&
                  passwordText == null &&
                  (isConsented || !needsConsent),
              focusNode: unlockFocus,
              label: passwordText == null ? 'Unlock' : 'Unlocking...',
              disabledOnPressed: () => setState(() {
                    if (!isConnected()) {
                      streams.app.behavior.snack.add(Snack(
                        message:
                            'Unable to connect! Please check connectivity.',
                      ));
                    }
                  }),
              onPressed: () async => submit())
        ],
      );
    });
  }

  bool isConnected() =>
      streams.client.connected.value == ConnectionStatus.connected;

  Future<bool> validate() async => services.password.validate.password(
      password: password.text,
      salt: await SecureStorage.authenticationKey,
      saltedHashedPassword: await getLatestSaltedHashedPassword());

  bool ancientValidate() {
    final String salt = pros.passwords.primaryIndex.getMostRecent()!.saltedHash;
    if (salt == 'deprecated') {
      return false;
    }
    return services.password.validate.ancientPassword(
        password: password.text,
        salt: pros.passwords.primaryIndex.getMostRecent()!.salt);
  }

  Future<void> submit({bool showFailureMessage = true}) async {
    // consent just once
    if (await HIVE_INIT.isPartiallyLoaded()) {
      finishLoadingWaiters();
      while (!(await HIVE_INIT.isLoaded())) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    }

    /// bridge
    if (ancientValidate()) {
      streams.app.behavior.snack.add(Snack(
          message: 'Migrating to latest version. Just a sec...',
          showOnLogin: true));
      setState(() => passwordText = password.text);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await populateWalletsWithSensitives();
      // first of all make a cipher for this
      services.cipher.initCiphers(
        altPassword: password.text,
        salt: DEFAULT_SALT,
      );
      await services.authentication.setPassword(
        password: password.text,
        salt: await SecureStorage.authenticationKey,
        saveSecret: SecureStorage.writeSecret,
      );

      /// lets not login this way again:
      await updatePasswordsToSecureStorage();

      /// bridge
      await updateWalletNames();
      await updateWalletsToSecureStorage();
      await updateEnumLowerCase();
      await updateChain();
      streams.app.behavior.scrim.add(null);
      streams.app.behavior.snack
          .add(Snack(message: 'Migration complete...', showOnLogin: true));

      await initiateLogin(password.text, refresh: true);
    } else if (await services.password.lockout
            .handleVerificationAttempt(await validate()) &&
        passwordText == null) {
      // only run once - disable button
      if (passwordText != password.text) {
        setState(() => passwordText = password.text);
      }
      initiateLogin(password.text,
          refresh: (services.version.snapshot?.currentBuild ?? 0) <=
                  (Platform.isIOS ? 20 : 4) &&
              (services.version.snapshot?.buildUpdated ?? false));
    } else {
      setState(() {
        failedAttempt = true;
        password.text = '';
      });
    }
  }

  Future<void> initiateLogin(
    String providedPassword, {
    bool refresh = false,
  }) async {
    /// there are existing wallets, we should populate them with sensitives now.
    await populateWalletsWithSensitives();
    if (!consented) {
      consented = await consentToAgreements(await getId());
    }
    if (refresh) {
      //services.download.overrideGettingStarted = true;
    }
    //try {
    //  Navigator.pushReplacementNamed(context, '/home', arguments: {});
    //} catch (e) {
    //  print(e);
    //}
    // create ciphers for wallets we have
    login(context, password: providedPassword);
    if (refresh) {
      streams.app.behavior.snack
          .add(Snack(message: 'Resyncing wallet...', showOnLogin: true));

      /// erase all history stuff
      await services.client.resetMemoryAndConnection(keepBalances: false);
      streams.app.wallet.refresh.add(true);
    }
  }
}
