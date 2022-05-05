import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/streams/app.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var password = TextEditingController();
  var passwordVisible = false;
  FocusNode loginFocus = FocusNode();
  FocusNode unlockFocus = FocusNode();
  DateTime lastFailedAttempt = DateTime.now();

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
              alignment: Alignment.center, height: 60, child: countdown),
        ),
        SliverToBoxAdapter(
          child: Container(
              alignment: Alignment.center, height: 80, child: loginField),
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
<<<<<<< HEAD
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
          height: 110,
        ),
=======
      Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Image(image: AssetImage('assets/logo/moontree.png')),
>>>>>>> 4085c657b56e43fd3ad9dd5e43ce4768618cdac7
        SizedBox(height: 8),
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headline1,
        ),
      ]);

  Widget get countdown => LockedOutTime(
        lastFailedAttempt: lastFailedAttempt,
        timeout: timeFromAttempts,
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
        errorText: password.text == '' && res.settings.loginAttempts > 0
            ? 'Incorrect Password'
            : null,
        //hintText:
        //    password.text == '' && res.settings.loginAttempts > 0 ? null : '',
        helperText: password.text == '' ? null : '',
        //suffixIcon: IconButton(
        //  icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off,
        //      color: AppColors.black60),
        //  onPressed: () => setState(() {
        //    passwordVisible = !passwordVisible;
        //  }),
        //),
      ),
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
          DateTime.now().difference(lastFailedAttempt).inMilliseconds >=
              timeFromAttempts,
      focusNode: unlockFocus,
      label: 'Unlock',
      disabledOnPressed: () => setState(() {}),
      onPressed: () async => await submit());

  Future<bool> validate() async {
    final x = services.password.validate.password(password.text);
    if (x) {
      if (res.settings.loginAttempts > 0) {
        streams.app.snack.add(Snack(
          message: res.settings.loginAttempts == 1
              ? 'There was ${res.settings.loginAttempts} unsuccessful login attempt'
              : 'There has been ${res.settings.loginAttempts} unsuccessful login attempts',
        ));
        await res.settings.resetLoginAttempts();
      }
    } else {
      await res.settings.incrementLoginAttempts();
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

  int get timeFromAttempts =>
      min(pow(2, res.settings.loginAttempts) * 125, 1000 * 60 * 60).toInt();
}
