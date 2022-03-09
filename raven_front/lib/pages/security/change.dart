import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';
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
  FocusNode existingPasswordFocusNode = FocusNode();
  FocusNode newPasswordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  String? newNotification;
  bool existingPasswordVisible = false;
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
    existingPassword.dispose();
    existingPasswordFocusNode.dispose();
    newPasswordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();

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
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: body(),
      );

  Widget body() => Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            if (!streams.app.verify.value) existingPasswordField,
            SizedBox(height: 16),
            newPasswordField,
            SizedBox(height: 16),
            confirmPasswordField
          ]),
          Row(children: [submitButton])
        ],
      ));

  Widget get existingPasswordField => TextField(
        focusNode: existingPasswordFocusNode,
        autocorrect: false,
        enabled: services.password.required ? true : false,
        controller: existingPassword,
        obscureText: !existingPasswordVisible,
        textInputAction: TextInputAction.next,
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'Current Password',
          helperText:
              existingPassword.text != '' && verify() ? 'sucess!' : null,
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
          setState(() {
            if (verify()) {
              FocusScope.of(context).requestFocus(newPasswordFocusNode);
            }
          });
        },
        onEditingComplete: () {
          if (verify()) {
            FocusScope.of(context).requestFocus(newPasswordFocusNode);
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

  Widget get confirmPasswordField => TextField(
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
        onEditingComplete: () async => await submit(),
      );

  Widget get submitButton => components.buttons.actionButton(
        context,
        label: 'Set',
        icon: Icon(Icons.lock_rounded),
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
    if (services.password.validate.complexity(newPassword.text)) {
      FocusScope.of(context).unfocus();
      streams.password.update.add(newPassword.text);
      components.loading.screen(message: 'Setting Password');
    }
  }
}
