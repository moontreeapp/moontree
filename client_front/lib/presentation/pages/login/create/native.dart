import 'package:flutter/material.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/services/services.dart' show sailor;

import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client_front/infrastructure/services/dev.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_back/services/consent.dart'
    show ConsentDocument, documentEndpoint, consentToAgreements;
import 'package:client_front/infrastructure/services/auth.dart';
import 'package:client_front/infrastructure/services/storage.dart'
    show SecureStorage;
import 'package:client_front/infrastructure/services/wallet.dart'
    show saveSecret, setupWallets;
import 'package:client_front/presentation/theme/extensions.dart';
import 'package:client_front/domain/utils/auth.dart';
import 'package:client_front/domain/utils/login.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/domain/utils/device.dart' show getId;
import 'package:client_front/domain/utils/extensions.dart';

class FrontCreateNativeScreen extends StatefulWidget {
  const FrontCreateNativeScreen({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('frontLoginCreateNative');
  @override
  _FrontCreateNativeState createState() => _FrontCreateNativeState();
}

class _FrontCreateNativeState extends State<FrontCreateNativeScreen> {
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
    needsConsent = data['needsConsent'] as bool? ?? false;
    return BackdropLayers(
        back: const BlankBack(), front: FrontCurve(child: body()));
  }

  Widget body() => FutureBuilder<bool>(
      future: localAuthApi.entirelyReadyToAuthenticate,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return GestureDetector(
            onTap: FocusScope.of(context).unfocus,
            child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 76.figmaH),
                            SizedBox(
                              height: 128.figmaH,
                              child: moontree,
                            ),
                            Container(
                                alignment: Alignment.bottomCenter,
                                height: (16 + 24).figmaH,
                                child: welcomeMessage),
                            Container(
                                alignment: Alignment.bottomCenter,
                                height: (16 + 24).figmaH,
                                child: labelMessage),
                            if (snapshot.hasData && !snapshot.data!)
                              Container(
                                  alignment: Alignment.center,
                                  height: (8 + 16 + 24).figmaH,
                                  child: setupMessage),
                          ]),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            if (needsConsent)
                              ulaMessage
                            else
                              const SizedBox(height: 100),
                            const SizedBox(height: 40),
                            Row(children: <Widget>[
                              if (snapshot.hasData)
                                snapshot.data! ? nativeButton : setupButton
                              else
                                const CircularProgressIndicator()
                            ]),
                            const SizedBox(height: 40),
                          ]),
                    ])));
      });

  Widget get moontree => SizedBox(
        height: .1534.ofMediaHeight(context),
        child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
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

  Widget get setupButton => components.buttons.actionButton(
        context,
        focusNode: unlockFocus,
        enabled: readyToUnlock(),
        label: 'Setup',
        onPressed: () async => submitSetup(),
      );

  Widget get nativeButton => components.buttons.actionButton(
        context,
        focusNode: unlockFocus,
        enabled: readyToUnlock(),
        label: enabled ? 'Create Wallet' : 'Creating Wallet...',
        onPressed: () async => submit(),
      );

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
        Future<Object?>.microtask(() => Navigator.pushReplacementNamed(
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
      enabled && (isConsented || !needsConsent);
}
