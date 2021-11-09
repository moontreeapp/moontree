import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/indicators/indicators.dart';
import 'package:raven_mobile/theme/extensions.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  var existingPassword = TextEditingController();
  var newPassword = TextEditingController();
  FocusNode newPasswordFocusNode = FocusNode();
  String existingNotification = '';
  String newNotification = '';
  bool existingPasswordVisible = false;
  bool newPasswordVisible = false;
  bool validatedExisting = false;
  bool? validatedComplexity;

  @override
  void initState() {
    existingPasswordVisible = false;
    newPasswordVisible = false;
    validatedExisting = false;
    super.initState();
  }

  @override
  void dispose() {
    existingPassword.dispose();
    newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: components.headers.back(context, 'Change Password'),
        body: body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: submitButton(),
      ));

  TextButton submitButton() => TextButton.icon(
      onPressed: validateExistingCondition(validatedExisting) &&
              validateComplexityCondition(validatedComplexity)
          ? () async => await submit()
          : () {},
      icon: Icon(Icons.login),
      style: validateExistingCondition(validatedExisting) &&
              validateComplexityCondition(validatedComplexity)
          ? components.buttonStyles.curvedSides
          : components.buttonStyles.disabledCurvedSides(context),
      label: Text('Submit',
          style: TextStyle(color: Theme.of(context).primaryColor)));

  bool validateExistingCondition([validatedExisting]) =>
      services.password.required
          ? validatedExisting ?? validateExisting()
          : true;

  bool validateComplexityCondition([givenValidatedComplexity]) =>
      givenValidatedComplexity ?? false ?? validateComplexity();

  Padding body() {
    var newPasswordField = TextField(
        focusNode: newPasswordFocusNode,
        autocorrect: false,
        controller: newPassword,
        obscureText: !newPasswordVisible,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: 'new password',
          suffixIcon: IconButton(
            icon: Icon(
                newPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).primaryColorDark),
            onPressed: () => setState(() {
              newPasswordVisible = !newPasswordVisible;
            }),
          ),
        ),
        onChanged: (String value) => validateComplexity(password: value),
        onEditingComplete: () async => await submit());
    var existingPasswordField = TextField(
      autocorrect: false,
      enabled: services.password.required ? true : false,
      controller: existingPassword,
      obscureText: !existingPasswordVisible,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        hintText: 'existing password',
        suffixIcon: IconButton(
          icon: Icon(
              existingPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).primaryColorDark),
          onPressed: () => setState(() {
            existingPasswordVisible = !existingPasswordVisible;
          }),
        ),
      ),
      onChanged: (String value) {
        if (validateExisting()) {
          FocusScope.of(context).requestFocus(newPasswordFocusNode);
        }
      },
      onEditingComplete: () => validateExisting(),
    );
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(height: 30),
            Column(children: [
              existingPasswordField,
              SizedBox(height: 5),
              Text(existingNotification,
                  style: TextStyle(
                      color: validatedExisting
                          ? Theme.of(context).good
                          : Theme.of(context).bad)),
            ]),
            Column(children: [
              newPasswordField,
              SizedBox(height: 5),
              Text(newNotification,
                  style: TextStyle(
                      color:
                          validatedComplexity == null || !validatedComplexity!
                              ? Theme.of(context).bad
                              : Theme.of(context).good))
            ]),
            SizedBox(height: 150),
          ],
        ));
  }

  bool validateExisting({String? password}) {
    password = password ?? existingPassword.text;
    if (services.password.validate.password(password)) {
      existingNotification = 'success!';
      validatedExisting = true;
      setState(() => {});
      return true;
    }
    var old = validatedExisting;
    var oldNotification = existingNotification;
    var used = services.password.validate.previouslyUsed(password);
    existingNotification = used == null
        ? 'password unrecognized...'
        : 'this password was used $used passwords ago';
    validatedExisting = false;
    if (old || oldNotification != existingNotification) setState(() => {});
    return false;
  }

  bool validateComplexity({String? password}) {
    password = password ?? newPassword.text;
    var used;
    var oldNotification = newNotification;
    if (services.password.validate.complexity(password)) {
      used = services.password.validate.previouslyUsed(password);
      newNotification = used == null
          ? 'This password has never been used and is a strong password'
          : used > 0
              ? 'Warnning: this password was used $used passwords ago'
              : 'This is your current password';
      if (used != 0) {
        validatedComplexity = true;
        setState(() => {});
        return true;
      }
    }
    var old = validatedComplexity;
    if (used != 0) {
      newNotification = ('weak password: '
          '${services.password.validate.complexityExplained(password).join(' & ')}.');
    }
    validatedComplexity = false;
    if (old != validatedComplexity || oldNotification != newNotification)
      setState(() => {});
    return false;
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future submit() async {
    if (validateComplexity() && validateExistingCondition()) {
      FocusScope.of(context).unfocus();
      var password = newPassword.text;
      await services.password.create.save(password);

      // todo: replace with responsive 'ecrypting wallet x, y, z... etc'
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
              title: Text('Re-encrypting Wallets...'),
              content: Text('Estimated wait time: ' +
                  _printDuration(Duration(seconds: wallets.data.length * 2)) +
                  ', please wait...')));
      // this is used to get the please wait message to show up
      // it needs enough time to display the message
      await Future.delayed(const Duration(milliseconds: 150));

      var cipher = services.cipher.updatePassword(altPassword: password);
      await services.cipher.updateWallets(cipher: cipher);
      services.cipher.cleanupCiphers();
      Navigator.of(context).pop(); // for please wait
      successMessage();
    }
  }

  Future successMessage() => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              title: Text('Success!'),
              content: Text('Please back up your password!\n\n'
                  'There is NO recovery process for lost passwords!'),
              actions: [
                TextButton(
                    child: Text('ok'),
                    onPressed: () {
                      validateComplexity();
                      Navigator.of(context).pop();
                    })
              ]));
}
