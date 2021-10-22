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
  FocusNode newPasswordFocusNode = new FocusNode();
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
      onPressed: validateExistingCondition(validatedExisting) &&
              validateComplexityCondition(validatedComplexity)
          ? () async => await submit()
          : () {},
      icon: Icon(Icons.login),
      style: validateExistingCondition(validatedExisting) &&
              validateComplexityCondition(validatedComplexity)
          ? RavenButtonStyle.curvedSides
          : RavenButtonStyle.disabledCurvedSides(context),
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
        onChanged: (String value) {
          validateComplexity(password: value);
          //setState(() => {});
        },
        onEditingComplete: () async {
          await submit();
        });
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
      onEditingComplete: () {
        validateExisting();
      },
      //onSubmitted: (String value) {
      //  setState(
      //      () => {});
      //},
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
              Text(existingNotification),
            ]),
            Column(children: [
              newPasswordField,
              SizedBox(height: 5),
              Text(newNotification),
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
        : 'this password was used $used passwords ago.';
    validatedExisting = false;
    if (old || oldNotification != existingNotification) setState(() => {});
    return false;
  }

  bool validateComplexity({String? password}) {
    password = password ?? newPassword.text;
    if (services.password.validate.complexity(password)) {
      var used = services.password.validate.previouslyUsed(password);
      newNotification = used == null
          ? 'This password has never been used and is a strong password.'
          : used > 0
              ? 'Warnning: this password was used $used passwords ago.'
              : 'This is your current password.';
      validatedComplexity = true;
      setState(() => {});
      return true;
    }
    var old = validatedComplexity;
    var oldNotification = newNotification;
    newNotification = ('weak password: '
        '${services.password.validate.complexityExplained(password).join(' & ')}.');
    validatedComplexity = false;
    if (old != validatedComplexity || oldNotification != newNotification)
      setState(() => {});
    return false;
    //setState(() => {});
  }

  Future submit() async {
    if (validateComplexity() && validateExistingCondition()) {
      var password = newPassword.text;
      await services.password.create.save(password);
      // save new cipher
      var cipher = services.cipher.updatePassword(altPassword: password);
      await services.cipher.updateWallets(cipher: cipher);
      services.cipher.cleanupCiphers();
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
