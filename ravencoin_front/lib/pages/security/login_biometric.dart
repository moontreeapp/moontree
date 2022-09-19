import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_back/services/consent.dart'
    show Consent, ConsentDocument, documentEndpoint;
import 'package:ravencoin_front/services/auth.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:ravencoin_front/theme/extensions.dart';
import 'package:ravencoin_front/utils/auth.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/utils/data.dart';
import 'package:ravencoin_front/utils/device.dart' show getId;
import 'package:ravencoin_front/utils/extensions.dart';
import 'package:ravencoin_front/services/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginBiometric extends StatefulWidget {
  @override
  _LoginBiometricState createState() => _LoginBiometricState();
}

class _LoginBiometricState extends State<LoginBiometric> {
  Map<String, dynamic> data = {};
  late List listeners = [];
  FocusNode unlockFocus = FocusNode();
  bool autoInitiateUnlock = true;
  bool enabled = true;
  bool isConsented = false;
  bool consented = false;
  late bool needsConsent;

  Future<void> finishLoadingDatabase() async {
    //if (!await finishedLoading) {
    if (await HIVE_INIT.isPartiallyLoaded()) {
      HIVE_INIT.setupDatabase2();
    }
    //}
  }

  Future<void> finishLoadingWaiters() async {
    if (await HIVE_INIT.isPartiallyLoaded()) {
      await HIVE_INIT.setupWaiters2();
    }
  }

  Future<bool> get finishedLoading async => await HIVE_INIT.isLoaded();

  @override
  void initState() {
    print('loading');
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
    unlockFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    needsConsent = data['needsConsent'] ?? false;
    if (readyToUnlock() && autoInitiateUnlock) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await submit();
      });
      autoInitiateUnlock = false;
    }
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
            SliverFillRemaining(
                hasScrollBody: false,
                child: KeyboardHidesWidgetWithDelay(
                    fade: true,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          (needsConsent ? ulaMessage : SizedBox(height: 100)),
                          SizedBox(height: 40),
                          Row(children: [bioButton]),
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

  bool readyToUnlock() =>
      isConnected() && enabled && ((isConsented) || !needsConsent);

  Widget get bioButton => components.buttons.actionButton(
        context,
        enabled: readyToUnlock(),
        label: enabled ? 'Unlock' : 'Unlocking...',
        onPressed: () async {
          await submit();
        },
      );

  Future submit() async {
    await setupWallets();

    /// just in case
    if (await HIVE_INIT.isPartiallyLoaded()) {
      finishLoadingWaiters();
      while (!(await HIVE_INIT.isLoaded())) {
        await Future.delayed(Duration(milliseconds: 50));
      }
    }
    //if (await services.password.lockout
    //        .handleVerificationAttempt(await validate()) &&
    //    passwordText == null) {
    setState(() => enabled = false);
    await consentToAgreements();
    final localAuthApi = LocalAuthApi();
    final x = await localAuthApi.authenticate();
    if (x) {
      await services.authentication.setPassword(
        password: await SecureStorage.authenticationKey,
        salt: await SecureStorage.authenticationKey,
      );
      Navigator.pushReplacementNamed(context, '/home', arguments: {});
      // create ciphers for wallets we have
      services.cipher.initCiphers(
        altPassword: await SecureStorage.authenticationKey,
        altSalt: await SecureStorage.authenticationKey,
      );
      await services.cipher.updateWallets();
      services.cipher.cleanupCiphers();
      services.cipher.loginTime();
      streams.app.splash.add(false); // trigger to refresh app bar again
      streams.app.logout.add(false);
      streams.app.verify.add(true);
    } else {
      setState(() => enabled = true);
      print(localAuthApi.reason);
      if (localAuthApi.reason == AuthenticationResult.error) {
        streams.app.snack.add(Snack(
          message: 'No pin detected; please set a password.',
        ));
        services.authentication.setMethod(method: AuthMethod.password);
        Future.microtask(() => Navigator.pushReplacementNamed(
              context,
              '/security/createlogin',
            ));
      }
    }
  }

  Future setupRealWallet(String? id) async {
    await dotenv.load(fileName: '.env');
    var mnemonic = id == null ? null : dotenv.env['TEST_WALLET_0$id']!;
    await services.wallet.createSave(
        walletType: WalletType.leader,
        cipherUpdate: services.cipher.currentCipherUpdate,
        secret: mnemonic);
  }

  Future setupWallets() async {
    if (pros.wallets.records.isEmpty) {
      await setupRealWallet(null);
      await pros.settings.setCurrentWalletId(pros.wallets.first.id);
      await pros.settings.savePreferredWalletId(pros.wallets.first.id);
    }
  }

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
}
