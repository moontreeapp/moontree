import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/services/services.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late List listeners = [];
  TextEditingController password = TextEditingController();
  bool passwordVisible = false;
  FocusNode loginFocus = FocusNode();
  FocusNode unlockFocus = FocusNode();
  String? passwordText;
  bool failedAttempt = false;

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
                          SizedBox(height: 100),
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
              res.settings.loginAttempts.length > 0 &&
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

  Widget get unlockButton => components.buttons.actionButton(context,
      enabled: password.text != '' &&
          services.password.lockout.timePast() &&
          passwordText == null,
      focusNode: unlockFocus,
      label: passwordText == null ? 'Unlock' : 'Unlocking...',
      disabledOnPressed: () => setState(() {}),
      onPressed: () async => await submit());

  bool validate() => services.password.validate.password(password.text);

  Future submit({bool showFailureMessage = true}) async {
    if (await HIVE_INIT.isPartiallyLoaded()) {
      finishLoadingWaiters();
      while (!(await HIVE_INIT.isLoaded())) {
        await Future.delayed(Duration(milliseconds: 1));
      }
    }
    if (await services.password.lockout.handleVerificationAttempt(validate()) &&
        passwordText == null) {
      setState(() {
        passwordText = password.text;
      }); // to disable the button visually
      await Future.delayed(Duration(milliseconds: 200)); // in release mode?
      Navigator.pushReplacementNamed(context, '/home', arguments: {});
      // create ciphers for wallets we have
      services.cipher.initCiphers(altPassword: password.text);
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
