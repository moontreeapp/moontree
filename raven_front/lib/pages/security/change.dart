import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/front/verify.dart';
import 'package:raven_front/theme/extensions.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  var newPassword = TextEditingController();
  var confirmPassword = TextEditingController();
  FocusNode newPasswordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  String newNotification = '';
  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;
  bool validatedExisting = false;
  bool validatedComplexity = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: streams.app.verify.value
            ? body()
            : VerifyPassword(parentState: this),
      );

  Widget body() {
    var newPasswordField = TextField(
      focusNode: newPasswordFocusNode,
      autocorrect: false,
      controller: newPassword,
      obscureText: !newPasswordVisible,
      textInputAction: TextInputAction.done,
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'new password',
        hintText: 'new password',
        helperText: validatedComplexity ? newNotification : null,
        errorText: !validatedComplexity && newNotification != ''
            ? newNotification
            : null,
        suffixIcon: IconButton(
          icon: Icon(
              newPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Color(0x99000000)),
          onPressed: () => setState(() {
            newPasswordVisible = !newPasswordVisible;
          }),
        ),
      ),
      onChanged: (String value) => validateComplexity(password: value),
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(confirmPasswordFocusNode),
    );
    var confirmPasswordField = TextField(
      focusNode: confirmPasswordFocusNode,
      autocorrect: false,
      controller: confirmPassword,
      obscureText: !confirmPasswordVisible,
      textInputAction: TextInputAction.done,
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'confirm password',
        hintText: 'confirm password',
        helperText: confirmPassword.text != '' &&
                confirmPassword.text == newPassword.text
            ? 'match'
            : null,
        errorText: confirmPassword.text == '' ||
                confirmPassword.text == newPassword.text
            ? null
            : 'do not match',
        suffixIcon: IconButton(
          icon: Icon(
              confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Color(0x99000000)),
          onPressed: () => setState(() {
            confirmPasswordVisible = !confirmPasswordVisible;
          }),
        ),
      ),
      onChanged: (String value) => setState(() {}),
      onEditingComplete: () async => await submit(),
    );
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  newPasswordField,
                  SizedBox(height: 16),
                  confirmPasswordField
                ]),
            Padding(
                padding: EdgeInsets.only(
                  top: 0,
                  bottom: 40,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [submitButton()]))
          ],
        ));
  }

  Widget submitButton() {
    var enabled =
        validatedComplexity && confirmPassword.text == newPassword.text;
    return Container(
        height: 40,
        child: OutlinedButton.icon(
            onPressed: enabled ? () async => await submit() : () {},
            icon: Icon(
              Icons.lock_rounded,
              color: enabled ? null : Color(0x61000000),
            ),
            label: Text(
              'Set'.toUpperCase(),
              style: enabled
                  ? Theme.of(context).navBarButton
                  : Theme.of(context).navBarButtonDisabled,
            ),
            style: components.styles.buttons.bottom(
              context,
              disabled: !enabled,
            )));
  }

  void validateComplexity({String? password}) {
    password = password ?? newPassword.text;
    var oldValidation = validatedComplexity;
    var oldNotification = newNotification;
    if (services.password.validate.complexity(password)) {
      var used = services.password.validate.previouslyUsed(password);
      newNotification = {
            null: 'strong',
            0: 'current',
            1: 'prior',
            2: 'password before last',
          }[used] ??
          'used $used passwords ago';
      // allow reuse of previous passwords?
      //if (used != 0) {
      if (used == null) {
        validatedComplexity = true;
      }
    } else {
      validatedComplexity = false;
      if (password == '') {
        newNotification = '';
      } else {
        newNotification =
            services.password.validate.complexityExplained(password)[0];
      }
    }
    if (oldValidation != validatedComplexity ||
        oldNotification != newNotification) {
      setState(() => {});
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future submit() async {
    if (services.password.validate.complexity(newPassword.text)) {
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
                    child:
                        Text('ok', style: Theme.of(context).sendConfirmButton),
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    })
              ]));
}
