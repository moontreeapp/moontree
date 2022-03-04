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

  @override
  void initState() {
    passwordVisible = false;
    super.initState();
  }

  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.height);
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
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Container(
          alignment: Alignment.bottomCenter,
          height: MediaQuery.of(context).size.height / 2,
          child: TextField(
              autocorrect: false,
              controller: password,
              obscureText: !passwordVisible,
              textInputAction: TextInputAction.done,
              decoration: components.styles.decorations.textFeild(
                context,
                labelText: 'password',
                suffixIcon: IconButton(
                  icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Color(0x99000000)),
                  onPressed: () => setState(() {
                    passwordVisible = !passwordVisible;
                  }),
                ),
              ),
              onChanged: (_) async => await submit(showFailureMessage: false),
              onEditingComplete: () async => await submit())));

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
      services.password.broadcastLogin;
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
