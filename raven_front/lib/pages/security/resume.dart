/// allow them to abort this process DONE
/// - and handle only being able to decrypt some wallets:
///   only matters when trying to backup wallets right?
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';

class ChangeResume extends StatefulWidget {
  @override
  _ChangeResumeState createState() => _ChangeResumeState();
}

class _ChangeResumeState extends State<ChangeResume> {
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
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //appBar: components.headers.simple(context, 'Password Recovery'),
        body: body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: submitButton(),
      ));

  Row submitButton() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(
                context, '/security/login', arguments: {}),
            icon: Icon(Icons.login),
            label: Text('Abort Password Change Process',
                style: TextStyle(color: Theme.of(context).primaryColor))),
        TextButton.icon(
            onPressed: () => submit(),
            icon: Icon(Icons.login),
            label: Text('Login',
                style: TextStyle(color: Theme.of(context).primaryColor))),
      ]);

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
                    hintText: 'previous password',
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
                  onEditingComplete: () => submit())),
        ],
      );

  void submit() {
    if (services.password.validate.previousPassword(password.text)) {
      FocusScope.of(context).unfocus();
      services.cipher.initCiphers(
        altPassword: password.text,
        currentCipherUpdates: services.wallet.getPreviousCipherUpdates,
      );
      successMessage();
    } else {
      var used = services.password.validate.previouslyUsed(password.text);
      failureMessage(used == null
          ? 'This password was not recognized to match any previously used passwords.'
          : 'The provided password was used $used passwords ago.');
    }
    setState(() => {});
  }

  Future failureMessage(String msg) => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              title: Text('Change Password Recovery failure'),
              content: Text('Previous password did not match. $msg'),
              actions: [
                TextButton(
                    child: Text('ok'), onPressed: () => Navigator.pop(context))
              ]));

  Future successMessage() => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              title: Text('Success!'),
              content:
                  Text('Previous password matched. Change password recovery '
                      'process will continue, please enter your current '
                      'password.'),
              actions: [
                TextButton(
                    child: Text('ok'),
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, '/security/login',
                        arguments: {}))
              ]));
}
