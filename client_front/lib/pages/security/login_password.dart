import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client_front/utils/login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_back/services/consent.dart'
    show ConsentDocument, documentEndpoint, consentToAgreements;
import 'package:client_front/components/components.dart';
import 'package:client_front/theme/colors.dart';
import 'package:client_front/theme/extensions.dart';
import 'package:client_front/utils/data.dart';
import 'package:client_front/utils/device.dart';
import 'package:client_front/utils/extensions.dart';
import 'package:client_front/widgets/widgets.dart';
import 'package:client_front/services/password.dart';
import 'package:client_front/services/services.dart';
import 'package:client_front/services/storage.dart' show SecureStorage;
import 'package:client_front/services/wallet.dart'
    show
        populateWalletsWithSensitives,
        updateChain,
        updateEnumLowerCase,
        updateWalletNames,
        updateWalletsToSecureStorage;

class LoginPassword extends StatefulWidget {
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
    listeners.add(streams.app.active.listen((bool value) {
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
    return BackdropLayers(
        back: const BlankBack(), front: FrontCurve(child: body()));
  }

  Widget body() => GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Container(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
          child: CustomScrollView(slivers: <Widget>[
            SliverToBoxAdapter(
              child: SizedBox(height: 76.figmaH),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 128.figmaH,
                child: moontree,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.bottomCenter,
                  height: (16 + 24).figmaH,
                  child: welcomeMessage),
            ),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 40.figma(context),
                  child: const LockedOutTime()),
            ),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.center, height: 120, child: loginField),
            ),
            SliverFillRemaining(
                hasScrollBody: false,
                child: KeyboardHidesWidgetWithDelay(
                    fade: true,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ...needsConsent
                              ? <Widget>[
                                  SizedBox(
                                    height: .063.ofMediaHeight(context),
                                  ),
                                  ulaMessage,
                                  SizedBox(
                                    height: .021.ofMediaHeight(context),
                                  ),
                                ]
                              : <Widget>[const SizedBox(height: 100)],
                          Row(children: <Widget>[unlockButton]),
                          const SizedBox(height: 40),
                        ]))),
          ])));

  Widget get moontree => SizedBox(
        height: .1534.ofMediaHeight(context),
        child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
      );

  Widget get welcomeMessage => Text(
        'Welcome Back',
        style: Theme.of(context)
            .textTheme
            .headline1
            ?.copyWith(color: AppColors.black60),
      );

  Widget get loginField => TextFieldFormatted(
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
        // might interfere with fade, but thats ok we took fade out.
        setState(() {});
      },
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(unlockFocus);
        setState(() {});
      });

  Widget get ulaMessage => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
              alignment: Alignment.center, width: 18, child: aggrementCheckbox),
          Container(
              alignment: Alignment.center,
              width: .70.ofMediaWidth(context),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(components.routes.routeContext!)
                      .textTheme
                      .bodyText2,
                  children: <TextSpan>[
                    const TextSpan(text: "I agree to Moontree's\n"),
                    TextSpan(
                        text: 'User Agreement',
                        style: Theme.of(components.routes.routeContext!)
                            .textTheme
                            .underlinedLink,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(documentEndpoint(
                                ConsentDocument.user_agreement)));
                          }),
                    const TextSpan(text: ', '),
                    TextSpan(
                        text: 'Privacy Policy',
                        style: Theme.of(components.routes.routeContext!)
                            .textTheme
                            .underlinedLink,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(documentEndpoint(
                                ConsentDocument.privacy_policy)));
                          }),
                    const TextSpan(text: ',\n and '),
                    TextSpan(
                        text: 'Risk Disclosure',
                        style: Theme.of(components.routes.routeContext!)
                            .textTheme
                            .underlinedLink,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(documentEndpoint(
                                ConsentDocument.risk_disclosures)));
                          }),
                  ],
                ),
              )),
          const SizedBox(
            width: 18,
          ),
        ],
      );

  Widget get aggrementCheckbox => Checkbox(
        //checkColor: Colors.white,
        value: isConsented,
        onChanged: (bool? value) async {
          setState(() {
            isConsented = value!;
          });
        },
      );

  bool isConnected() =>
      streams.client.connected.value == ConnectionStatus.connected;

  Widget get unlockButton => components.buttons.actionButton(context,
      enabled: password.text != '' &&
          services.password.lockout.timePast() &&
          passwordText == null &&
          (isConsented || !needsConsent),
      focusNode: unlockFocus,
      label: passwordText == null ? 'Unlock' : 'Unlocking...',
      disabledOnPressed: () => setState(() {
            if (!isConnected()) {
              streams.app.snack.add(Snack(
                message: 'Unable to connect! Please check connectivity.',
              ));
            }
          }),
      onPressed: () async => submit());

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
      streams.app.snack.add(Snack(
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
      streams.app.scrim.add(null);
      streams.app.snack
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

  Future<void> initiateLogin(String providedPassword,
      {bool refresh = false}) async {
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
      streams.app.snack
          .add(Snack(message: 'Resyncing wallet...', showOnLogin: true));

      /// erase all history stuff
      await services.client.resetMemoryAndConnection(keepBalances: false);
      services.download.overrideGettingStarted = true;
      streams.app.wallet.refresh.add(true);
    }
  }
}

/*
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  final storage = new FlutterSecureStorage();

  // Read value
  String value = await storage.read(key: key);

  // Write value
  await storage.write(key: key, value: value);
  */
