import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven/utils/validate.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var password = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(),
      body: body(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: submitButton(),
    );
  }

  AppBar header() =>
      AppBar(elevation: 2, centerTitle: false, title: Text('Login'));

  TextButton submitButton() {
    return TextButton.icon(
        onPressed: () => submit(),
        icon: Icon(Icons.login),
        label: Text('Login',
            style: TextStyle(color: Theme.of(context).primaryColor)));
  }

  Column body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.all(20.0),
            child: TextField(
                autocorrect: false,
                controller: password,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(), hintText: ('password')),
                onEditingComplete: () => submit())),
      ],
    );
  }

  void submit() {
    if (verifyPassword(password.text)) {
      // use password to generate ciphers
      cipherRegistry.initCiphers(services.wallets.getCurrentCipherUpdates,
          altPassword: password.text);
      // check for wallet encryption state (interrupted password change):
      //// if there are wallets on an old password version
      ////// ask for old password, create those ciphers, continue conversion process
      //// else if there are wallets on a previous CipherType:
      ////// use current password to generate previous ciphertype ciphers and convert old wallets to new ciphertype
      // redirect to home
      Navigator.pushReplacementNamed(context, '/home', arguments: {});
    } else {
      // password didn't match message
      failureMessage();
    }
    setState(() => {});
  }

  Future failureMessage() {
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
                title: Text('Login failure'),
                content: Text('password did not match'),
                actions: [
                  TextButton(
                      child: Text('ok'),
                      onPressed: () => Navigator.pop(context))
                ]));
  }
}

//asdf = fd80cb8b18e1f2b044c8341e9bf79bcb6b66d9490a72bc1d16a65b043700456f
