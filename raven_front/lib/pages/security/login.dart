import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var password = TextEditingController();
  var passwordVisible = false;
  bool buttonEnabled = false;
  FocusNode loginFocus = FocusNode();
  FocusNode unlockFocus = FocusNode();

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
    return body();
  }

  Widget body() => Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      child: CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
          child: Container(
              height: MediaQuery.of(context).size.height / 3 + 16 + 16,
              child: welcomeMessage),
        ),
        SliverToBoxAdapter(
          child: Container(
              alignment: Alignment.center, height: 70, child: loginField),
        ),
        SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 100),
                  Row(children: [unlockButton]),
                  SizedBox(height: 40),
                ])),
      ]));

  Widget get welcomeMessage =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image(image: AssetImage('assets/logo/moontree.png')),
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
      decoration: components.styles.decorations.textFeild(
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
      onChanged: (_) {
        setState(() {});
      },
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(unlockFocus);
        setState(() {});
      });

  Widget get unlockButton => components.buttons.actionButton(context,
      enabled: validate(),
      focusNode: unlockFocus,
      onPressed: () async => await submit());

  bool validate() => services.password.validate.password(password.text);

  Future submit({bool showFailureMessage = true}) async {
    if (services.password.validate.password(password.text)) {
      setState(() {
        buttonEnabled = true;
      });
      FocusScope.of(context).unfocus();
      // create ciphers for wallets we have
      services.cipher.initCiphers(altPassword: password.text);
      await services.cipher.updateWallets();
      services.cipher.cleanupCiphers();
      Navigator.pushReplacementNamed(context, '/home', arguments: {});
    } else {
      buttonEnabled = false;
    }
  }
}
