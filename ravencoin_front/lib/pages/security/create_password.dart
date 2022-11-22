import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/services/wallet.dart'
    show populateWalletsWithSensitives, saveSecret, setupWallets;
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_back/services/consent.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/theme/extensions.dart';
import 'package:ravencoin_front/utils/device.dart';
import 'package:ravencoin_front/utils/extensions.dart';
import 'package:ravencoin_front/utils/login.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class CreatePassword extends StatefulWidget {
  @override
  _CreatePasswordState createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  //late List listeners = [];
  var password = TextEditingController();
  var confirm = TextEditingController();
  var passwordVisible = false;
  var confirmVisible = false;
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmFocus = FocusNode();
  FocusNode unlockFocus = FocusNode();
  bool noPassword = true;
  String? passwordText;
  bool consented = false;
  bool isConsented = false;
  final int minimumLength = 1;

  @override
  void initState() {
    super.initState();
    //listeners.add(streams.password.exists.listen((bool value) {
    //  if (value && noPassword) {
    //    noPassword = false;
    //    //exitProcess();
    //  }
    //}));
  }

  @override
  void dispose() {
    //for (var listener in listeners) {
    //  listener.cancel();
    //}
    password.dispose();
    confirm.dispose();
    passwordFocus.dispose();
    confirmFocus.dispose();
    unlockFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(back: BlankBack(), front: FrontCurve(child: body()));
  }

  Widget body() => GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: CustomScrollView(slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.bottomCenter,
                  height: .242.ofMediaHeight(context),
                  child: moontree),
            ),
            SliverToBoxAdapter(
                child: SizedBox(height: .01.ofMediaHeight(context))),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.bottomCenter,
                  height: .035.ofMediaHeight(context),
                  child: welcomeMessage),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: .0789.ofMediaHeight(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.topCenter,
                  // height: 76,
                  height: .0947.ofMediaHeight(context),
                  child: passwordField),
            ),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.topCenter,
                  // height: 76 + 16,
                  height: .0947.ofMediaHeight(context),
                  child: confirmField),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            SliverToBoxAdapter(
              child: Container(
                alignment: Alignment.topCenter,
                child: components.text.passwordWarning,
              ),
            ),
            SliverFillRemaining(
                hasScrollBody: false,
                child: KeyboardHidesWidgetWithDelay(
                    fade: true,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: .063.ofMediaHeight(context),
                          ),
                          ulaMessage,
                          SizedBox(
                            height: .021.ofMediaHeight(context),
                          ),
                          Row(children: [unlockButton]),
                          SizedBox(
                            height: .052.ofMediaHeight(context),
                          ),
                        ]))),
          ])));

  Widget get moontree => Container(
        child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
        height: .1534.ofMediaHeight(context),
        // height: 110.figma(context),
      );

  Widget get welcomeMessage => Text('Moontree',
      style: Theme.of(context)
          .textTheme
          .headline1
          ?.copyWith(color: AppColors.black60));

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

  Widget get passwordField => TextFieldFormatted(
      onTap: () => setState(() {}),
      focusNode: passwordFocus,
      autocorrect: false,
      controller: password,
      obscureText: !passwordVisible,
      textInputAction: TextInputAction.next,
      labelText: 'Password',
      errorText: password.text != '' && password.text.length < minimumLength
          ? 'password must be at least $minimumLength characters long'
          : null,
      helperText: !(password.text != '' && password.text.length < minimumLength)
          ? ''
          : null,
      suffixIcon: IconButton(
        icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.black60),
        onPressed: () => setState(() {
          passwordVisible = !passwordVisible;
        }),
      ),
      onChanged: (_) => setState(() {}),
      onEditingComplete: () {
        setState(() {});
        if (password.text != '' && password.text.length >= minimumLength) {
          FocusScope.of(context).requestFocus(confirmFocus);
        }
      });

  Widget get confirmField => TextFieldFormatted(
      onTap: () => setState(() {}),
      focusNode: confirmFocus,
      autocorrect: false,
      controller: confirm,
      obscureText: !confirmVisible, // masked controller for immediate?
      textInputAction: TextInputAction.done,
      labelText: 'Confirm Password',
      errorText: confirm.text != '' && confirm.text != password.text
          ? 'does not match password'
          : null,
      helperText: confirm.text == password.text ? 'match' : null,
      suffixIcon: IconButton(
        icon: Icon(confirmVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.black60),
        onPressed: () => setState(() {
          confirmVisible = !confirmVisible;
        }),
      ),
      onChanged: (_) => setState(() {}),
      onEditingComplete: () {
        setState(() {});
        if (confirm.text == password.text) {
          FocusScope.of(context).requestFocus(unlockFocus);
        }
      });

  bool isConnected() =>
      streams.client.connected.value == ConnectionStatus.connected;

  Widget get unlockButton => components.buttons.actionButton(context,
      enabled: isConnected() && validate(),
      focusNode: unlockFocus,
      label: passwordText == null ? 'Create Wallet' : 'Creating Wallet...',
      disabledOnPressed: () => setState(() {
            if (!isConnected()) {
              streams.app.snack.add(Snack(
                message: 'Unable to connect! Please check connectivity.',
              ));
            }
          }),
      onPressed: () async => await submit());

  Widget get aggrementCheckbox => Checkbox(
        //checkColor: Colors.white,
        value: isConsented,
        onChanged: (bool? value) async {
          setState(() {
            isConsented = value!;
          });
        },
      );

  bool validate() {
    return passwordText == null &&
        password.text.length >= minimumLength &&
        confirm.text == password.text &&
        isConsented;
  }

  Future consentToAgreements() async {
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
    // since the concent calls take some time, maybe this should be removed...?
    if (validate()) {
      // only run once - disable button
      setState(() => passwordText = password.text);
      await services.authentication
          .setMethod(method: AuthMethod.moontreePassword);
      await consentToAgreements();
      //await Future.delayed(Duration(milliseconds: 200)); // in release mode?
      await populateWalletsWithSensitives();
      await services.authentication.setPassword(
        password: password.text,
        salt: await SecureStorage.authenticationKey,
        message: '',
        saveSecret: saveSecret,
      );
      await exitProcess();
    } else {
      setState(() {
        password.text = '';
      });
    }
  }

  Future<void> exitProcess() async {
    await setupWallets();
    login(context, password: password.text);
  }
}
