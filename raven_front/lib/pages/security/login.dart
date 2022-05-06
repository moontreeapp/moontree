import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/streams/app.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController password = TextEditingController();
  bool passwordVisible = false;
  FocusNode loginFocus = FocusNode();
  FocusNode unlockFocus = FocusNode();
  bool failedAttempt = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    password.dispose();
    loginFocus.dispose();
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
              alignment: Alignment.center, height: 60, child: LockedOutTime()),
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
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
          height: 110,
        ),
        SizedBox(height: 8),
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headline1,
        ),
      ]);

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
        errorText: password.text == '' &&
                res.settings.loginAttempts.length > 0 &&
                failedAttempt
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
      enabled: password.text != '' && services.password.lockout.timePast(),
      focusNode: unlockFocus,
      label: 'Unlock',
      disabledOnPressed: () => setState(() {}),
      onPressed: () async => await submit());

  bool validate() => services.password.validate.password(password.text);

  Future submit({bool showFailureMessage = true}) async {
    if (await services.password.lockout.handleVerificationAttempt(validate())) {
      await Future.delayed(Duration(milliseconds: 200)); // in release mode?
      FocusScope.of(context).unfocus();
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
