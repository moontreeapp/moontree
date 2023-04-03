import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_front/presentation/components/components.dart';
import 'package:client_back/services/consent.dart'
    show ConsentDocument, documentEndpoint, consentToAgreements;
import 'package:client_front/infrastructure/services/auth.dart';
import 'package:client_front/infrastructure/services/dev.dart';
import 'package:client_front/infrastructure/services/wallet.dart'
    show populateWalletsWithSensitives;
import 'package:client_front/presentation/theme/extensions.dart';
import 'package:client_front/domain/utils/auth.dart';
import 'package:client_front/domain/utils/login.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/domain/utils/device.dart' show getId;
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/infrastructure/services/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginNative extends StatefulWidget {
  @override
  _LoginNativeState createState() => _LoginNativeState();
}

class _LoginNativeState extends State<LoginNative> {
  Map<String, dynamic> data = <String, dynamic>{};
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  FocusNode unlockFocus = FocusNode();
  bool? autoInitiateUnlock;
  bool enabled = true;
  bool failedAttempt = false;
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
    unlockFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      data = populateData(context, data);
    } catch (e) {
      data = <String, dynamic>{};
    }
    needsConsent = data['needsConsent'] as bool? ?? false;
    autoInitiateUnlock =
        autoInitiateUnlock ?? data['autoInitiateUnlock'] as bool? ?? true;
    if (readyToUnlock() && autoInitiateUnlock!) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await submit();
      });
      autoInitiateUnlock = false;
    }
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
                        children: <Widget>[
                          (needsConsent
                              ? ulaMessage
                              : const SizedBox(height: 100)),
                          const SizedBox(height: 40),
                          Row(children: <Widget>[bioButton]),
                          const SizedBox(height: 40),
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

  Widget get bioButton => components.buttons.actionButton(
        context,
        focusNode: unlockFocus,
        enabled: readyToUnlock(),
        label: enabled ? 'Unlock' : 'Unlocking...',
        onPressed: () async {
          await submit();
        },
      );

  Future<void> submit() async {
    /// just in case
    if (await HIVE_INIT.isPartiallyLoaded()) {
      await finishLoadingWaiters();

      /// doesn't await work?
      //while (!(await HIVE_INIT.isLoaded())) {
      //  await Future<void>.delayed(const Duration(milliseconds: 50));
      //}
    }

    /// there are existing wallets, we should populate them with sensitives now.
    await populateWalletsWithSensitives();
    final LocalAuthApi localAuthApi = LocalAuthApi();
    streams.app.authenticating.add(true);
    final bool validate = await localAuthApi.authenticate(
        skip: devFlags.contains(DevFlag.skipPin));
    streams.app.authenticating.add(false);
    setState(() => enabled = false);
    if (await services.password.lockout.handleVerificationAttempt(validate)) {
      if (!consented) {
        consented = await consentToAgreements(await getId());
      }
      login(context);
    } else {
      /// this is a pretty wild edge case:
      /// they were able to set nativeSecurity up but now its not working anymore
      if (localAuthApi.reason == AuthenticationResult.error) {
        streams.app.snack.add(Snack(
            message: 'Unknown login error: please set a pin on the device.',
            showOnLogin: true));
        setState(() => enabled = true);
        await Navigator.pushReplacementNamed(
          context,
          getMethodPathLogin(nativeSecurity: false),
        );
        streams.app.snack.add(Snack(
            message: 'Please set a password to secure your wallet.',
            showOnLogin: true));
      } else if (localAuthApi.reason == AuthenticationResult.failure) {
        /// while testing removal of pin after setting up native auth on ios, it
        /// seems this is the failure that occures, so the user is stuck on the
        /// login streen indefinately. works fine on android.
        /// we'll probably update the design to push them back to the create
        /// login process, allowing them to set a password... until then ios
        /// will be stuck because if we can't differentiate between .error and
        /// .failure we can't allow them to get through.
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
