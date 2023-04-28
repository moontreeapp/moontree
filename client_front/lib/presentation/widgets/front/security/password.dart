import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/storage.dart'
    show SecureStorage;
import 'package:client_front/infrastructure/services/wallet.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({Key? key, this.data}) : super(key: key);
  final dynamic data;

  @override
  _ChangePasswordWidget createState() => _ChangePasswordWidget();
}

class _ChangePasswordWidget extends State<ChangePasswordWidget> {
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
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
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16, bottom: 16),
                child: Container(
                    alignment: Alignment.topLeft, child: newPasswordField))),
        SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16, bottom: 16),
                child: Container(
                    alignment: Alignment.topLeft,
                    child: confirmPasswordField))),
        SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16, bottom: 16),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Center(child: components.text.passwordWarning),
                ))),
        SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16, bottom: 16),
                child: Container(
                    alignment: Alignment.topLeft,
                    child: Row(children: <Widget>[submitButton])))),
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
              color: const Color(0x99000000)),
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
              color: const Color(0x99000000)),
          onPressed: () => setState(() {
            confirmPasswordVisible = !confirmPasswordVisible;
          }),
        ),
        onChanged: (String value) => validateComplexity(),
        //onEditingComplete: () async =>  submit(),
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
        disabledIcon: const Icon(Icons.lock_rounded, color: AppColors.black38),
        onPressed: () async => submit(),
      );

  bool enabledCheck() =>
      validatedComplexity && confirmPassword.text == newPassword.text;

  void validateComplexity({String? password}) {
    password = password ?? newPassword.text;
    bool oldValidation = validatedComplexity;
    String? oldNotification = newNotification;
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
      setState(() {});
    }
  }

  //String _printDuration(Duration duration) {
  //  String twoDigits(int n) => n.toString().padLeft(2, "0");
  //  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  //  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  //  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  //}

  Future<void> submit() async {
    await Future<void>.delayed(
        const Duration(milliseconds: 200)); // in release mode?
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
