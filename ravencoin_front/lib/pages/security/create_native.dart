import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_back/services/consent.dart'
    show ConsentDocument, documentEndpoint, consentToAgreements;
import 'package:ravencoin_front/services/auth.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:ravencoin_front/services/wallet.dart'
    show saveSecret, setupWallets;
import 'package:ravencoin_front/theme/extensions.dart';
import 'package:ravencoin_front/utils/auth.dart';
import 'package:ravencoin_front/utils/login.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/utils/data.dart';
import 'package:ravencoin_front/utils/device.dart' show getId;
import 'package:ravencoin_front/utils/extensions.dart';

class CreateNative extends StatefulWidget {
  @override
  _CreateNativeState createState() => _CreateNativeState();
}

class _CreateNativeState extends State<CreateNative> {
  Map<String, dynamic> data = {};
  late List listeners = [];
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
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    needsConsent = data['needsConsent'] ?? false;
    return BackdropLayers(back: BlankBack(), front: FrontCurve(child: body()));
  }

  Widget body() => FutureBuilder<bool>(
      future: localAuthApi.entirelyReadyToAuthenticate,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        return GestureDetector(
            onTap: FocusScope.of(context).unfocus,
            child: Container(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
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
                        height: (16 + 24).figmaH,
                        child: labelMessage),
                  ),
                  if (snapshot.hasData && !snapshot.data!)
                    SliverToBoxAdapter(
                      child: Container(
                          alignment: Alignment.center,
                          height: (8 + 16 + 24).figmaH,
                          child: setupMessage),
                    ),
                  SliverFillRemaining(
                      hasScrollBody: false,
                      child: KeyboardHidesWidgetWithDelay(
                          fade: true,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                (needsConsent
                                    ? ulaMessage
                                    : SizedBox(height: 100)),
                                SizedBox(height: 40),
                                Row(children: [
                                  snapshot.hasData
                                      ? snapshot.data!
                                          ? nativeButton
                                          : setupButton
                                      : CircularProgressIndicator()
                                ]),
                                SizedBox(height: 40),
                              ]))),
                ])));
      });

  Widget get moontree => Container(
        child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
        height: .1534.ofMediaHeight(context),
      );

  Widget get welcomeMessage => Text(
        'Moontree',
        style: Theme.of(context)
            .textTheme
            .headline1
            ?.copyWith(color: AppColors.black60),
      );

  Widget get labelMessage => Text(
        "${Platform.isIOS ? 'iOS' : 'Android'} Phone Security",
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.black),
      );

  Widget get setupMessage => Text(
        'Please setup Face, Fingerprints, Pattern, PIN, or Password',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle2!
            .copyWith(color: AppColors.black, fontWeight: FontWeight.w600),
      );

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

  Widget get setupButton => components.buttons.actionButton(
        context,
        focusNode: unlockFocus,
        enabled: readyToUnlock(),
        label: 'Setup',
        onPressed: () async => await submitSetup(),
      );

  Widget get nativeButton => components.buttons.actionButton(
        context,
        focusNode: unlockFocus,
        enabled: readyToUnlock(),
        label: enabled ? 'Create Wallet' : 'Creating Wallet...',
        onPressed: () async => await submit(),
      );

  Future submitSetup() async {
    if (Platform.isIOS) {
      await AppSettings.openSecuritySettings();
    } else {
      await AppSettings.openSecuritySettings();
      // android only alternative
      //import 'package:open_settings/open_settings.dart';
      //await OpenSettings.openSecuritySetting();
    }
  }

  Future submit() async {
    setState(() => enabled = false);
    streams.app.authenticating.add(true);
    final validate = await localAuthApi.authenticate();
    streams.app.authenticating.add(false);
    if (await services.password.lockout.handleVerificationAttempt(validate)) {
      final key = await SecureStorage.authenticationKey;

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
        Future.microtask(() => Navigator.pushReplacementNamed(
              context,
              getMethodPathCreate(nativeSecurity: false),
            ));
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
      enabled && ((isConsented) || !needsConsent);
}
