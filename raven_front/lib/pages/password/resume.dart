/// allow them to abort this process DONE
/// - and handle only being able to decrypt some wallets
/// also create password creation and recreatiuon process - warn them if the password has been used before.
import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/styles/buttons.dart';

class ChangeResume extends StatefulWidget {
  @override
  _ChangeResumeState createState() => _ChangeResumeState();
}

class _ChangeResumeState extends State<ChangeResume> {
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

  AppBar header() => AppBar(
      elevation: 2,
      centerTitle: false,
      title: Text('Change Password Process Recovery'));

  Row submitButton() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login',
                arguments: {}),
            icon: Icon(Icons.login),
            style: RavenButtonStyle.leftSideCurved,
            label: Text('Abort Password Change Process',
                style: TextStyle(color: Theme.of(context).primaryColor))),
        TextButton.icon(
            onPressed: () => submit(),
            icon: Icon(Icons.login),
            style: RavenButtonStyle.rightSideCurved(context),
            label: Text('Login',
                style: TextStyle(color: Theme.of(context).primaryColor))),
      ]);

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
                    border: UnderlineInputBorder(),
                    hintText: ('previous password')),
                onEditingComplete: () => submit())),
      ],
    );
  }

  void submit() {
    if (services.passwords.verifyPreviousPassword(password.text)) {
      cipherRegistry.initCiphers(services.wallets.getPreviousCipherUpdates,
          altPassword: password.text);
      successMessage();
    } else {
      var used = services.passwords.verifyUsed(password.text);
      failureMessage(used == -1
          ? 'This password was not recognized to match any previously used passwords.'
          : 'It seems the provided password was used $used passwords ago.');
    }
    setState(() => {});
  }

  Future failureMessage(String msg) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
                title: Text('Change Password Recovery failure'),
                content: Text('Previous password did not match. $msg'),
                actions: [
                  TextButton(
                      child: Text('ok'),
                      onPressed: () => Navigator.pop(context))
                ]));
  }

  Future successMessage() {
    return showDialog(
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
}
