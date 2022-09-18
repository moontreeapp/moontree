import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/consent.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/theme/extensions.dart';
import 'package:ravencoin_front/utils/data.dart';
import 'package:ravencoin_front/utils/device.dart';
import 'package:ravencoin_front/utils/extensions.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_front/services/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPassword extends StatefulWidget {
  @override
  _LoginPasswordState createState() => _LoginPasswordState();
}

class _LoginPasswordState extends State<LoginPassword> {
  late List listeners = [];
  TextEditingController password = TextEditingController();
  bool passwordVisible = false;
  FocusNode loginFocus = FocusNode();
  FocusNode unlockFocus = FocusNode();
  String? passwordText;
  bool failedAttempt = false;
  bool isConsented = false;
  bool consented = false;
  Map<String, dynamic> data = {};
  late bool needsConsent;

  Future<void> finishLoadingDatabase() async {
    if (await HIVE_INIT.isPartiallyLoaded()) {
      HIVE_INIT.setupDatabase2();
    }
  }

  Future<void> finishLoadingWaiters() async {
    if (await HIVE_INIT.isPartiallyLoaded()) {
      await HIVE_INIT.setupWaiters2();
    }
  }

  Future<bool> get finishedLoading async => await HIVE_INIT.isLoaded();

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
    for (var listener in listeners) {
      listener.cancel();
    }
    password.dispose();
    loginFocus.dispose();
    unlockFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    needsConsent = data['needsConsent'] ?? false;
    return BackdropLayers(back: BlankBack(), front: FrontCurve(child: body()));
  }

  Widget body() => GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
          child: CustomScrollView(slivers: <Widget>[
            SliverToBoxAdapter(
              child: SizedBox(height: 76.figmaH),
            ),
            SliverToBoxAdapter(
              child: Container(
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
                  child: LockedOutTime()),
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
                        children: [
                          ...(needsConsent
                              ? [
                                  SizedBox(
                                    height: .063.ofMediaHeight(context),
                                  ),
                                  ulaMessage,
                                  SizedBox(
                                    height: .021.ofMediaHeight(context),
                                  ),
                                ]
                              : [SizedBox(height: 100)]),
                          Row(children: [unlockButton]),
                          SizedBox(height: 40),
                        ]))),
          ])));

  Widget get moontree => Container(
        child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
        height: .1534.ofMediaHeight(context),
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
        children: [
          Container(
              alignment: Alignment.center, width: 18, child: aggrementCheckbox),
          Container(
              alignment: Alignment.center,
              width: .70.ofMediaWidth(context),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(components.navigator.routeContext!)
                      .textTheme
                      .bodyText2,
                  children: <TextSpan>[
                    TextSpan(text: "I agree to Moontree's\n"),
                    TextSpan(
                        text: 'User Agreement',
                        style: Theme.of(components.navigator.routeContext!)
                            .textTheme
                            .underlinedLink,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(documentEndpoint(
                                ConsentDocument.user_agreement)));
                          }),
                    TextSpan(text: ', '),
                    TextSpan(
                        text: 'Privacy Policy',
                        style: Theme.of(components.navigator.routeContext!)
                            .textTheme
                            .underlinedLink,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(documentEndpoint(
                                ConsentDocument.privacy_policy)));
                          }),
                    TextSpan(text: ',\n and '),
                    TextSpan(
                        text: 'Risk Disclosure',
                        style: Theme.of(components.navigator.routeContext!)
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
          SizedBox(
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
      enabled: isConnected() &&
          password.text != '' &&
          services.password.lockout.timePast() &&
          passwordText == null &&
          ((isConsented) || !needsConsent),
      focusNode: unlockFocus,
      label: passwordText == null ? 'Unlock' : 'Unlocking...',
      disabledOnPressed: () => setState(() {
            if (!isConnected()) {
              streams.app.snack.add(Snack(
                message: 'Unable to connect! Please check connectivity.',
              ));
            }
          }),
      onPressed: () async => await submit());

  bool validate() => services.password.validate.password(password.text);

  Future consentToAgreements() async {
    //uploadNewDocument();
    // consent just once
    if (!consented) {
      final consent = Consent();
      await consent.given(await getId(), ConsentDocument.user_agreement);
      await consent.given(await getId(), ConsentDocument.privacy_policy);
      await consent.given(await getId(), ConsentDocument.risk_disclosures);
      consented = true;
    }
  }

  Future submit({bool showFailureMessage = true}) async {
    // consent just once
    if (await HIVE_INIT.isPartiallyLoaded()) {
      finishLoadingWaiters();
      while (!(await HIVE_INIT.isLoaded())) {
        await Future.delayed(Duration(milliseconds: 1));
      }
    }
    if (await services.password.lockout.handleVerificationAttempt(validate()) &&
        passwordText == null) {
      // only run once - disable button
      setState(() => passwordText = password.text);
      await consentToAgreements();
      Navigator.pushReplacementNamed(context, '/home', arguments: {});
      // create ciphers for wallets we have
      services.cipher.initCiphers(
        altPassword: password.text,
        altSalt: await SecureStorage.biometricKey,
      );
      await services.cipher.updateWallets();
      services.cipher.cleanupCiphers();
      services.cipher.loginTime();
      streams.app.splash.add(false); // trigger to refresh app bar again
      streams.app.logout.add(false);
      streams.app.verify.add(true);
    } else {
      setState(() {
        failedAttempt = true;
        password.text = '';
      });
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
