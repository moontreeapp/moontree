import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/widgets/widgets.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  var existingPassword = TextEditingController();
  var newPassword = TextEditingController();
  var confirmPassword = TextEditingController();
  FocusNode existingPasswordFocus = FocusNode();
  FocusNode newPasswordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  FocusNode buttonFocus = FocusNode();
  String? newNotification;
  bool existingPasswordVisible = false;
  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;
  bool validatedExisting = false;
  bool validatedComplexity = false;

  @override
  void initState() {
    super.initState();
    print('streams.app.verify.value ${streams.app.verify.value}');
  }

  @override
  void dispose() {
    newPassword.dispose();
    confirmPassword.dispose();
    existingPassword.dispose();
    existingPasswordFocus.dispose();
    newPasswordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  /// this is removed because instead of using a separate page to handle
  /// current password validation we've added that functionality directly into
  /// this page. this is pretty nice though, and shows an example of how to
  /// rebuild a parent from a child.
  //@override
  //Widget build(BuildContext context) => GestureDetector(
  //      onTap: () => FocusScope.of(context).unfocus(),
  //      child: streams.app.verify.value
  //          ? body()
  //          : VerifyPassword(parentState: this),
  //    );

  @override
  Widget build(BuildContext context) => BackdropLayers(
      back: BlankBack(),
      front: FrontCurve(
          child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: streams.app.verify.value
            ? body()
            : VerifyPassword(parentState: this, buttonLabel: 'Change Password'),
      )));

  Widget body() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              for (var x in [
                if (!streams.app.verify.value) existingPasswordField,
                newPasswordField,
                confirmPasswordField,
              ])
                Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: x)
            ],
          ),
          KeyboardHidesWidgetWithDelay(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                Center(child: components.text.passwordWarning),
                SizedBox(height: 50),
                components.containers
                    .navBar(context, child: Row(children: [submitButton]))
              ]))
        ],
      );

  Widget get existingPasswordField => TextField(
        focusNode: existingPasswordFocus,
        autocorrect: false,
        enabled: services.password.required ? true : false,
        controller: existingPassword,
        obscureText: !existingPasswordVisible,
        textInputAction: TextInputAction.next,
        decoration: components.styles.decorations.textField(
          context,
          labelText: 'Current Password',
          //helperText:
          //    existingPassword.text != '' && verify() ? 'Verified' : null,
          errorText: existingPassword.text != '' && !verify() ? used() : null,
          suffixIcon: IconButton(
            icon: Icon(
                existingPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Color(0x99000000)),
            onPressed: () => setState(() {
              existingPasswordVisible = !existingPasswordVisible;
            }),
          ),
        ),
        onChanged: (String value) {
          //setState(() {
          //  if (verify()) {
          //    FocusScope.of(context).requestFocus(newPasswordFocus);
          //  }
          //});
        },
        onEditingComplete: () {
          if (verify()) {
            setState(() {
              FocusScope.of(context).requestFocus(newPasswordFocus);
            });
          }
        },
      );

  bool verify() =>
      services.password.validate.password(existingPassword.text); // &&
  //services.password.validate.previouslyUsed(existingPassword.text) == 0;
  String used() =>
      {
        null: 'unrecognized',
        //0: 'current password',
        //1: 'prior password',
        //2: 'password before last',
      }[services.password.validate.previouslyUsed(existingPassword.text)] ??
      //'has been used before';
      'unrecognized';

  Widget get newPasswordField => TextField(
        focusNode: newPasswordFocus,
        autocorrect: false,
        controller: newPassword,
        obscureText: !newPasswordVisible,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textField(
          context,
          labelText: 'New Password',
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
            FocusScope.of(context).requestFocus(confirmPasswordFocus),
      );

  Widget get confirmPasswordField => TextField(
        focusNode: confirmPasswordFocus,
        autocorrect: false,
        controller: confirmPassword,
        obscureText: !confirmPasswordVisible,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textField(
          context,
          labelText: 'Confirm New Password',
          helperText: confirmPassword.text != '' &&
                  confirmPassword.text == newPassword.text
              ? 'Match'
              : null,
          errorText: confirmPassword.text == '' ||
                  confirmPassword.text == newPassword.text
              ? null
              : 'No Match',
          suffixIcon: IconButton(
            icon: Icon(
                confirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Color(0x99000000)),
            onPressed: () => setState(() {
              confirmPasswordVisible = !confirmPasswordVisible;
            }),
          ),
        ),
        onChanged: (String value) => validateComplexity(),
        //onEditingComplete: () async => await submit(),
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(buttonFocus),

        /// should we just dismiss the keyboard instead of submitting?
        // FocusManager.instance.primaryFocus?.unfocus();
      );

  Widget get submitButton => components.buttons.actionButton(
        context,
        label: 'Set',
        focusNode: buttonFocus,
        disabledIcon: Icon(Icons.lock_rounded, color: AppColors.black38),
        onPressed: () async => await submit(),
        enabled: enabledCheck(),
      );

  bool enabledCheck() =>
      (!streams.app.verify.value ? verify() : true) &&
      validatedComplexity &&
      confirmPassword.text == newPassword.text;

  void validateComplexity({String? password}) {
    password = password ?? newPassword.text;
    var oldValidation = validatedComplexity;
    var oldNotification = newNotification;
    if (services.password.validate.complexity(password)) {
      if (confirmPassword.text == newPassword.text) {
        validatedComplexity = true;
      } else {
        validatedComplexity = false;
      }
    } else {
      validatedComplexity = false;
      if (password == '') {
        newNotification = null;
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

  //String _printDuration(Duration duration) {
  //  String twoDigits(int n) => n.toString().padLeft(2, "0");
  //  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  //  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  //  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  //}

  Future submit() async {
    await Future.delayed(Duration(milliseconds: 200));
    if (services.password.validate.complexity(newPassword.text)) {
      FocusScope.of(context).unfocus();
      streams.password.update.add(newPassword.text);
      components.loading.screen(message: 'Setting Password', staticImage: true);
    }
  }
}
