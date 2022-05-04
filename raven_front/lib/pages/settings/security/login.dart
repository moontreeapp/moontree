import 'dart:math';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/widgets/widgets.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var password = TextEditingController();
  var passwordVisible = false;
  FocusNode loginFocus = FocusNode();
  FocusNode unlockFocus = FocusNode();
  // milliseconds
  int timeout = max(
      res.settings.primaryIndex
              .getOne(SettingName.Lockout_Milliseconds)
              ?.value ??
          0,
      125);
  DateTime lastFailedAttempt = DateTime.now();
  bool showCountdown = false;

  @override
  void initState() {
    passwordVisible = false;
    super.initState();
  }

  @override
  void dispose() {
    password.dispose();
    unlockFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(back: BlankBack(), front: FrontCurve(child: body()));
  }

  Widget body() => Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      child: CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
          child: Container(
              height: MediaQuery.of(context).size.height / 3 + 16 + 16 - 70,
              child: welcomeMessage),
        ),
        SliverToBoxAdapter(
          child: Container(
              alignment: Alignment.center, height: 70, child: countdown),
        ),
        SliverToBoxAdapter(
          child: Container(
              alignment: Alignment.center, height: 70, child: loginField),
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
      ]));

  Widget get welcomeMessage =>
      Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Image(image: AssetImage('assets/logo/moontree.png')),
        SizedBox(height: 8),
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headline1,
        ),
      ]);

  Widget get countdown => LockedOutTime(
        lastFailedAttempt: lastFailedAttempt,
        timeout: timeout,
      );

  Widget get loginField => TextField(
      focusNode: loginFocus,
      autocorrect: false,
      controller: password,
      obscureText: !passwordVisible, // masked controller for immediate?
      textInputAction: TextInputAction.done,
      decoration: components.styles.decorations.textField(
        context,
        focusNode: loginFocus,
        labelText: 'Password',
        //suffixIcon: IconButton(
        //  icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off,
        //      color: AppColors.black60),
        //  onPressed: () => setState(() {
        //    passwordVisible = !passwordVisible;
        //  }),
        //),
      ),
      onChanged: (_) => setState(() {}),
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(unlockFocus);
        setState(() {});
      });

  Widget get unlockButton => components.buttons.actionButton(context,
      enabled: password.text != '' &&
          DateTime.now().difference(lastFailedAttempt).inMilliseconds >=
              timeout,
      focusNode: unlockFocus,
      label: 'Unlock',
      disabledOnPressed: () => setState(() => showCountdown = true),
      onPressed: () async => await submit());

  Future<bool> validate() async {
    var x = services.password.validate.password(password.text);
    if (x) {
      timeout = 0;
      await res.settings.save(
          Setting(name: SettingName.Lockout_Milliseconds, value: timeout));
    } else {
      timeout = min(timeout + timeout, 1000 * 60 * 60);
      await res.settings.save(
          Setting(name: SettingName.Lockout_Milliseconds, value: timeout));
      lastFailedAttempt = DateTime.now();
    }
    return x;
  }

  Future submit({bool showFailureMessage = true}) async {
    if (await validate()) {
      await Future.delayed(Duration(milliseconds: 200));
      FocusScope.of(context).unfocus();
      Navigator.pushReplacementNamed(context, '/home', arguments: {});
      // create ciphers for wallets we have
      services.cipher.initCiphers(altPassword: password.text);
      await services.cipher.updateWallets();
      services.cipher.cleanupCiphers();
      services.cipher.loginTime();
      streams.app.splash.add(false); // trigger to refresh app bar again
      streams.app.logout.add(false);
    } else {
      setState(() {
        password.text = '';
      });
    }
  }
}
