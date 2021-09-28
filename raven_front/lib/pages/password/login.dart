import 'package:flutter/material.dart';
import 'package:raven/raven.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var password = TextEditingController();
  var passwordVisible = false;

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
  Widget build(BuildContext context) => Scaffold(
        appBar: header(),
        body: body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: submitButton(),
      );

  AppBar header() =>
      AppBar(elevation: 2, centerTitle: false, title: Text('Login'));

  TextButton submitButton() => TextButton.icon(
      onPressed: () async => await submit(),
      icon: Icon(Icons.login),
      label: Text('Login',
          style: TextStyle(color: Theme.of(context).primaryColor)));

  Column body() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                  autocorrect: false,
                  controller: password,
                  obscureText: !passwordVisible,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'password',
                    suffixIcon: IconButton(
                      icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark),
                      onPressed: () => setState(() {
                        passwordVisible = !passwordVisible;
                      }),
                    ),
                  ),
                  onEditingComplete: () async => await submit())),
        ],
      );

  Future submit() async {
    if (services.passwords.validate.password(password.text)) {
      // create ciphers for wallets we have
      cipherRegistry.initCiphers(services.wallets.getCurrentCipherUpdates,
          altPassword: password.text);
      await cipherRegistry.updateWallets();
      cipherRegistry.cleanupCiphers();
      services.passwords.broadcastLogin;
      Navigator.pushReplacementNamed(context, '/home', arguments: {});
    } else {
      var used = services.passwords.validate.previouslyUsed(password.text);
      failureMessage(used == -1
          ? 'This password was not recognized to match any previously used passwords.'
          : 'The provided password was used $used passwords ago.');
    }
    setState(() => {});
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
