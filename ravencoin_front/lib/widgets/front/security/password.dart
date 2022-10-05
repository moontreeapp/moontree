import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:ravencoin_front/services/wallet.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class ChangePasswordWidget extends StatefulWidget {
  final dynamic data;
  const ChangePasswordWidget({this.data}) : super();

  @override
  _ChangePasswordWidget createState() => _ChangePasswordWidget();
}

class _ChangePasswordWidget extends State<ChangePasswordWidget> {
  var newPassword = TextEditingController();
  var confirmPassword = TextEditingController();
  FocusNode newPasswordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  FocusNode buttonFocus = FocusNode();
  String? newNotification;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
            child: Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                child: Container(
                    alignment: Alignment.topLeft, child: newPasswordField))),
        SliverToBoxAdapter(
            child: Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                child: Container(
                    alignment: Alignment.topLeft,
                    child: confirmPasswordField))),
        SliverToBoxAdapter(
            child: Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Center(child: components.text.passwordWarning),
                ))),
        SliverToBoxAdapter(
            child: Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                child: Container(
                    alignment: Alignment.topLeft,
                    child: Row(children: [submitButton])))),
      ]);

  Widget get newPasswordField => TextFieldFormatted(
        focusNode: newPasswordFocus,
        autocorrect: false,
        controller: newPassword,
        obscureText: !newPasswordVisible,
        textInputAction: TextInputAction.done,
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
        onChanged: (String value) => validateComplexity(password: value),
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(confirmPasswordFocus),
      );

  Widget get confirmPasswordField => TextFieldFormatted(
        focusNode: confirmPasswordFocus,
        autocorrect: false,
        controller: confirmPassword,
        obscureText: !confirmPasswordVisible,
        textInputAction: TextInputAction.done,

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
              confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Color(0x99000000)),
          onPressed: () => setState(() {
            confirmPasswordVisible = !confirmPasswordVisible;
          }),
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
        enabled: enabledCheck(),
        label: 'Set',
        focusNode: buttonFocus,
        disabledIcon: Icon(Icons.lock_rounded, color: AppColors.black38),
        onPressed: () async => await submit(),
      );

  bool enabledCheck() =>
      validatedComplexity && confirmPassword.text == newPassword.text;

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
    await Future.delayed(Duration(milliseconds: 200)); // in release mode?
    if (services.password.validate.complexity(newPassword.text)) {
      FocusScope.of(context).unfocus();
      services.authentication.setPassword(
        password: newPassword.text,
        salt: await SecureStorage.authenticationKey,
        message: 'Successfully Updated Password',
        saveSecret: saveSecret,
      );
      await components.loading.screen(
          message: 'Setting Password', staticImage: true, returnHome: false);
      Navigator.of(context).pop();
    }
  }
}