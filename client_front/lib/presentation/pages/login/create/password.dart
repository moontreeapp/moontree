import 'dart:async';
import 'package:client_front/presentation/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/consent.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_front/domain/utils/device.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/domain/utils/login.dart';
import 'package:client_front/infrastructure/services/wallet.dart'
    show populateWalletsWithSensitives, saveSecret, setupWallets;
import 'package:client_front/infrastructure/services/storage.dart'
    show SecureStorage;
import 'package:client_front/application/app/login/cubit.dart';
import 'package:client_front/presentation/widgets/login/components.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

class LoginCreatePassword extends StatefulWidget {
  const LoginCreatePassword({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('LoginCreatePassword');
  @override
  _LoginCreatePasswordState createState() => _LoginCreatePasswordState();
}

class _LoginCreatePasswordState extends State<LoginCreatePassword> {
  //late List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  TextEditingController password = TextEditingController();
  TextEditingController confirm = TextEditingController();
  bool passwordVisible = false;
  bool confirmVisible = false;
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
    //for (final StreamSubscription<dynamic>> listener in listeners) {
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
    return BlocBuilder<LoginCubit, LoginCubitState>(builder: (context, state) {
      isConsented = state.isConsented;
      return PageStructure(
        children: [
          if (screen.app.height >= 640) SizedBox(height: 16),
          if (screen.app.height >= 640)
            Container(
                alignment: Alignment.bottomCenter,
                //height: .242.ofMediaHeight(context),
                child: MoontreeLogo()),
          //SizedBox(height: .01.ofMediaHeight(context)),
          Container(
              alignment: Alignment.bottomCenter,
              //height: .035.ofMediaHeight(context),
              child: WelcomeMessage()),
          //SizedBox(
          //  height: .0789.ofMediaHeight(context),
          //),
          if (screen.app.height >= 640) SizedBox(height: 0),
          Container(
              alignment: Alignment.topCenter,
              //height: 76,
              //height: .0947.ofMediaHeight(context),
              child: TextFieldFormatted(
                  onTap: () => setState(() {}),
                  focusNode: passwordFocus,
                  autocorrect: false,
                  controller: password,
                  obscureText: !passwordVisible,
                  textInputAction: TextInputAction.next,
                  labelText: 'Password',
                  errorText: password.text != '' &&
                          password.text.length < minimumLength
                      ? 'password must be at least $minimumLength characters long'
                      : null,
                  helperText: !(password.text != '' &&
                          password.text.length < minimumLength)
                      ? ''
                      : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.black60),
                    onPressed: () => setState(() {
                      passwordVisible = !passwordVisible;
                    }),
                  ),
                  onChanged: (_) => setState(() {}),
                  onEditingComplete: () {
                    setState(() {});
                    if (password.text != '' &&
                        password.text.length >= minimumLength) {
                      FocusScope.of(context).requestFocus(confirmFocus);
                    }
                  })),
          Container(
              alignment: Alignment.topCenter,
              // height: 76 + 16,
              height: .0947.ofMediaHeight(context),
              child: TextFieldFormatted(
                  onTap: () => setState(() {}),
                  focusNode: confirmFocus,
                  autocorrect: false,
                  controller: confirm,
                  obscureText:
                      !confirmVisible, // masked controller for immediate?
                  textInputAction: TextInputAction.done,
                  labelText: 'Confirm Password',
                  errorText: confirm.text != '' && confirm.text != password.text
                      ? 'does not match password'
                      : null,
                  helperText: confirm.text == password.text ? 'match' : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                        confirmVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                  })),
          //SizedBox(height: 16),
          Container(
            alignment: Alignment.topCenter,
            child: components.text.passwordWarning,
          ),
        ],
        firstLowerChildren: [UlaMessage()],
        secondLowerChildren: [
          BottomButton(
              enabled: isConnected() && validate(),
              focusNode: unlockFocus,
              label:
                  passwordText == null ? 'Create Wallet' : 'Creating Wallet...',
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

  bool validate() {
    return passwordText == null &&
        password.text.length >= minimumLength &&
        confirm.text == password.text &&
        isConsented;
  }

  Future<void> consentToAgreements() async {
    // consent just once
    if (!consented) {
      final Consent consent = Consent();
      await consent.given(await getId(), ConsentDocument.user_agreement);
      await consent.given(await getId(), ConsentDocument.privacy_policy);
      await consent.given(await getId(), ConsentDocument.risk_disclosures);
      consented = true;
    }
  }

  Future<void> submit({bool showFailureMessage = true}) async {
    // since the concent calls take some time, maybe this should be removed...?
    if (validate()) {
      // only run once - disable button
      setState(() => passwordText = password.text);
      await services.authentication
          .setMethod(method: AuthMethod.moontreePassword);
      await consentToAgreements();
      //await Future<void>.delayed(const Duration(milliseconds: 200)); // in release mode?
      await populateWalletsWithSensitives();
      await services.authentication.setPassword(
        password: password.text,
        //salt: password.text, // we should salt it with the password itself...
        /// if we salt with this we must provide it to them for decrypting
        /// exports, which means since this is the way it already is, this will
        /// require a migration or a password reset before the export feature is
        /// made available... unless we don't encrypt exports...
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
    components.cubits.loadingView
        .show(title: 'Creating Wallet', msg: 'one moment please');
    //await components.loading.screen(
    //  message: 'Creating Wallet',
    //  returnHome: false,
    //  playCount: 4,
    //);
    await setupWallets();
    login(context, password: password.text);
    components.cubits.loadingView.hide();
  }
}
