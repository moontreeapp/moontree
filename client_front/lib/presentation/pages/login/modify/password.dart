import 'dart:async';

import 'package:client_front/presentation/services/services.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/storage.dart'
    show SecureStorage;
import 'package:client_front/infrastructure/services/wallet.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

class ChangeLoginPassword extends StatefulWidget {
  const ChangeLoginPassword({super.key});

  @override
  _ChangeLoginPasswordState createState() => _ChangeLoginPasswordState();
}

class _ChangeLoginPasswordState extends State<ChangeLoginPassword> {
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  Map<String, dynamic> data = <String, dynamic>{};
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
    streams.app.auth.verify.add(false);
    listeners.add(streams.app.auth.verify.listen((value) {
      if (value == true) {
        if (mounted) {
          setState(() {});
        }
      }
    }));
  }

  @override
  void dispose() {
    newPassword.dispose();
    confirmPassword.dispose();
    newPasswordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      data = populateData(context, data);
    } catch (e) {
      data = <String, dynamic>{};
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: services.password.askCondition
          ? VerifyAuthentication(
              buttonLabel: data['verification.ButtonLabel'] as String? ??
                  'Change Password')
          : body(),
    );
  }

  Widget body() => PageStructure(
        children: <Widget>[
          for (Widget x in <Widget>[
            TextFieldFormatted(
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
                    newPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: const Color(0x99000000)),
                onPressed: () => setState(() {
                  newPasswordVisible = !newPasswordVisible;
                }),
              ),
              onChanged: (String value) => validateComplexity(password: value),
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(confirmPasswordFocus),
            ),
            TextFieldFormatted(
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
                    confirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
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
            ),
          ])
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: x)
        ],
        firstLowerChildren: [
          Center(child: components.text.passwordWarning),
        ],
        secondLowerChildren: [
          BottomButton(
            enabled: enabledCheck(),
            label: 'Set',
            focusNode: buttonFocus,
            disabledIcon:
                const Icon(Icons.lock_rounded, color: AppColors.black38),
            onPressed: () async => submit(),
          ),
        ],
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
    components.cubits.loadingView
        .show(title: 'Setting Password', msg: 'just a sec');
    await Future<void>.delayed(
        const Duration(milliseconds: 200)); // in release mode?
    if (services.password.validate.complexity(newPassword.text)) {
      FocusScope.of(context).unfocus();
      // unawait, but do these in order:
      () async {
        await services.authentication.setPassword(
          password: newPassword.text,
          salt: await SecureStorage.authenticationKey,
          message: 'Successfully Updated Security',
          saveSecret: saveSecret,
        );
        if (data.containsKey('then')) {
          await (data['then'] as Function())();
        }
        if (data.containsKey('then.then')) {
          await (data['then.then'] as Function())();
        }
      }();
      //components.loading.screen(
      //  message: 'Setting Password',
      //  staticImage: true,
      //  returnHome: false,
      //  //returnHome: data['onSuccess.returnHome'] as bool? ?? true,
      //);
      //if (data['onSuccess.returnHome'] as bool? ?? true) {
      //  sail.home();
      //}
      components.cubits.loadingView.hide();
      sail.back();
    }
  }
}
