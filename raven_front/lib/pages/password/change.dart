import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/styles/buttons.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  var existingPassword = TextEditingController();
  var newPassword = TextEditingController();
  String existingNotification = '';
  String newNotification = '';
  bool existingPasswordVisible = false;
  bool newPasswordVisible = false;
  bool submitEnabled = false;
  bool validatedExisting = false;
  bool validatedComplexity = false;

  @override
  void initState() {
    existingPasswordVisible = false;
    newPasswordVisible = false;
    submitEnabled = false;
    validatedExisting = false;
    validatedComplexity = false;
    super.initState();
  }

  @override
  void dispose() {
    existingPassword.dispose();
    newPassword.dispose();
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
      leading: RavenButton.back(context),
      elevation: 2,
      centerTitle: false,
      title: Text('Change Password'));

  TextButton submitButton() => TextButton.icon(
      onPressed: submitEnabled ? () async => await submit() : () {},
      icon: Icon(Icons.login),
      style: submitEnabled
          ? RavenButtonStyle.curvedSides
          : RavenButtonStyle.disabledCurvedSides(context),
      label: Text('Submit',
          style: TextStyle(color: Theme.of(context).primaryColor)));

  Padding body() => Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
              autocorrect: false,
              controller: existingPassword,
              obscureText: !existingPasswordVisible,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'existing password',
                suffixIcon: IconButton(
                  icon: Icon(
                      existingPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark),
                  onPressed: () => setState(() {
                    existingPasswordVisible = !existingPasswordVisible;
                  }),
                ),
              ),
              onChanged: (String value) {
                // validate its the current password as we go?
                //existingNotification = value;
              },
              onEditingComplete: () {
                validatedExisting = validateExisting();
              }),
          SizedBox(height: 5),
          Text(existingNotification),
          SizedBox(height: 30),
          TextField(
              autocorrect: false,
              controller: newPassword,
              obscureText: !newPasswordVisible,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'new password',
                suffixIcon: IconButton(
                  icon: Icon(
                      newPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark),
                  onPressed: () => setState(() {
                    newPasswordVisible = !newPasswordVisible;
                  }),
                ),
              ),
              onChanged: (String value) {
                validatedComplexity = validateComplexity(password: value);
              },
              onEditingComplete: () async {
                await submit();
              }),
          SizedBox(height: 5),
          Text(newNotification),
          SizedBox(height: 30),
        ],
      ));

  bool validateExisting({String? password}) {
    if (services.passwords.validate
        .password(password ?? existingPassword.text)) {
      existingNotification = 'success!';
      submitEnabled = validatedExisting;
      return true;
    }
    existingNotification = 'unable to login...';
    submitEnabled = false;
    return false;
    //setState(() => {}); // needed?
  }

  bool validateComplexity({String? password}) {
    password = password ?? newPassword.text;
    if (services.passwords.validate.complexity(password)) {
      var used = services.passwords.validate.previouslyUsed(password);
      newNotification = used == -1
          ? 'This password has never been used and is a strong password.'
          : 'Warnning: this password was used $used passwords ago.';
      submitEnabled = validatedExisting;
      return true;
    }
    // TODO: turn into a list of items that get checked off
    newNotification = ('weak password: '
        'must contain a number '
        'and be at least 12 characters long.');
    submitEnabled = false;
    return false;
    //setState(() => {}); // needed?
  }

  Future submit() async {
    if (validateComplexity() && validateExisting()) {
      var password = newPassword.text;
      await services.passwords.create.save(password);
      cipherRegistry.initCiphers(services.wallets.getCurrentCipherUpdates,
          altPassword: password);
      await cipherRegistry.updateWallets();
      cipherRegistry.cleanupCiphers();
      successMessage();
    }
  }

  Future successMessage() => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              title: Text('Success!'),
              content: Text(
                  'Password Change Successful! Please back up your password! '
                  'There is no recovery process available for lost passwords!'),
              actions: [
                TextButton(
                    child: Text('ok'),
                    onPressed: () => Navigator.of(context).pop())
              ]));
}
