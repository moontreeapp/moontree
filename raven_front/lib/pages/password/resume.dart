/// allow them to abort this process DONE
/// - and handle only being able to decrypt some wallets:
///   only matters when trying to backup wallets right?
import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/indicators/indicators.dart';

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
  Widget build(BuildContext context) => Scaffold(
        appBar: header(),
        body: body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: submitButton(),
      );

  AppBar header() => AppBar(
        elevation: 2,
        centerTitle: false,
        title: Text('Change Password Process Recovery'),
        actions: [
          components.status,
          indicators.process,
          indicators.client,
        ],
      );

  Row submitButton() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login',
                arguments: {}),
            icon: Icon(Icons.login),
            style: components.buttonStyles.leftSideCurved,
            label: Text('Abort Password Change Process',
                style: TextStyle(color: Theme.of(context).primaryColor))),
        TextButton.icon(
            onPressed: () => submit(),
            icon: Icon(Icons.login),
            style: components.buttonStyles.rightSideCurved(context),
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
                        context, '/login',
                        arguments: {}))
              ]));
}
