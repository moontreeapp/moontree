import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var password = TextEditingController();
  var passwordVisible = false;
  bool buttonEnabled = false;
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

  ElevatedButton submitButton() => ElevatedButton.icon(
      onPressed: () async => await submit(),
      icon: Icon(Icons.login),
      label: Text('Login'),
      style: buttonEnabled
          ? null
          : ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).disabledColor)));

  Widget body() => Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      child: CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
          child: Container(
              height: (MediaQuery.of(context).size.height - 16 - 40 - 70) / 2,
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
                  SizedBox(height: 80),
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
      autocorrect: false,
      controller: password,
      obscureText: !passwordVisible,
      textInputAction: TextInputAction.done,
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'password',
        suffixIcon: IconButton(
          icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.black60),
          onPressed: () => setState(() {
            passwordVisible = !passwordVisible;
          }),
        ),
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

  Future fakeSubmit({bool showFailureMessage = true}) =>
      Navigator.pushReplacementNamed(context, '/home', arguments: {});

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
      if (showFailureMessage) {
        var used = services.password.validate.previouslyUsed(password.text);
        failureMessage(used == null
            ? 'This password was not recognized to match any previously used passwords.'
            : 'The provided password was used $used passwords ago.');
        setState(() => {});
      }
    }
  }

  Future failureMessage(String msg) => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              title: Text('Login failure'),
              content: Text('password did not match. $msg'),
              actions: [
                TextButton(
                    child: Text('ok'), onPressed: () => Navigator.pop(context))
              ]));
}

//asdf = fd80cb8b18e1f2b044c8341e9bf79bcb6b66d9490a72bc1d16a65b043700456f
