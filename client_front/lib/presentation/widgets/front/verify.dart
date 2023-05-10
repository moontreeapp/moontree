import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/styles/styles.dart'
    as styles;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/auth.dart';
import 'package:client_front/infrastructure/services/dev.dart';
import 'package:client_front/infrastructure/services/password.dart';
import 'package:client_front/infrastructure/services/storage.dart'
    show SecureStorage;
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

class VerifyAuthentication extends StatelessWidget {
  final String buttonLabel;
  final String? suffix;
  final Widget? intro;
  final bool auto;
  final bool asLoginTime;

  const VerifyAuthentication({
    Key? key,
    this.buttonLabel = 'Submit',
    this.suffix,
    this.intro,
    this.auto = true,
    this.asLoginTime = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = <String, dynamic>{};
    try {
      data = populateData(context, data);
    } catch (e) {
      data = <String, dynamic>{};
    }
    if (pros.settings.authMethodIsNativeSecurity) {
      return AuthenticateByNative(data: data);
    } else {
      return AuthenticateByPassword(
        data: data,
        buttonLabel: buttonLabel,
        intro: intro,
      );
    }
  }
}

class AuthenticateByPassword extends StatefulWidget {
  final String? buttonLabel;
  final Widget? intro;
  final Map<String, dynamic> data;
  const AuthenticateByPassword(
      {super.key, this.buttonLabel, this.intro, required this.data});

  @override
  _AuthenticateByPasswordState createState() => _AuthenticateByPasswordState();
}

class _AuthenticateByPasswordState extends State<AuthenticateByPassword> {
  TextEditingController password = TextEditingController();
  bool passwordVisible = false;
  FocusNode existingFocus = FocusNode();
  FocusNode submitFocus = FocusNode();
  bool failedAttempt = false;
  bool enabled = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    password.dispose();
    existingFocus.dispose();
    submitFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageStructure(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (widget.intro != null) widget.intro!,
          Container(
              height: ((MediaQuery.of(context).size.height) -
                      (56 +
                          40 +
                          16 +
                          16 +
                          72.figma(context) +
                          (widget.intro != null ? 40.figma(context) : 0))) /
                  3),
          const LockedOutTime(),
          passwordField,
        ],
        firstLowerChildren: <Widget>[submitButton],
      );

  Widget get passwordField => TextField(
        focusNode: existingFocus,
        autocorrect: false,
        enabled: services.password.required ? true : false,
        controller: password,
        obscureText: !passwordVisible,
        textInputAction: TextInputAction.done,
        decoration: styles.decorations.textField(
          components.routes.context!,
          focusNode: existingFocus,
          labelText: 'Password',
          errorText: password.text == '' &&
                  pros.settings.loginAttempts.isNotEmpty &&
                  failedAttempt
              ? 'Incorrect Password'
              : null,
          //suffixIcon: IconButton(
          //  icon: Icon(
          //      passwordVisible
          //          ? Icons.visibility
          //          : Icons.visibility_off,
          //      color: AppColors.black60),
          //  onPressed: () => setState(() {
          //    passwordVisible = !passwordVisible;
          //  }),
          //),
        ),
        onEditingComplete: () {
          setState(() {});
          FocusScope.of(context).requestFocus(submitFocus);
        },
      );

  Widget get submitButton => BottomButton(
        focusNode: submitFocus,
        enabled: password.text != '' && services.password.lockout.timePast(),
        label: widget.data['buttonLabel'] as String? ??
            widget.buttonLabel ??
            'Submit',
        onPressed: submitProceedure,
      );

  Future<bool> verify() async => services.password.validate.password(
        password: password.text,
        salt: await SecureStorage.authenticationKey,
        saltedHashedPassword: await getLatestSaltedHashedPassword(),
      ); // &&
  //services.password.validate.previouslyUsed(password.text) == 0;

  Future<void> submitProceedure() async {
    if (await services.password.lockout
        .handleVerificationAttempt(await verify())) {
      streams.app.auth.verify.add(true);
      (widget.data['onSuccess'] ?? () {})();
    } else {
      setState(() {
        failedAttempt = true;
        password.text = '';
      });
    }
  }

  String used() =>
      <int?, String>{
        null: 'unrecognized',
        //0: 'current password',
        //1: 'prior password',
        //2: 'password before last',
      }[services.password.validate.previouslyUsed(password.text)] ??
      //'has been used before';
      'unrecognized';
}

class AuthenticateByNative extends StatelessWidget {
  final Map<String, dynamic> data;
  const AuthenticateByNative({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    //if (widget.auto &&
    // pros.settings.authMethodIsNativeSecurity &&
    //   (data['autoInitiateUnlock'] as bool? ?? true)) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await submit();
    });
    data['autoInitiateUnlock'] = false;
    //}
    return PageStructure(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
            child: Text(
          'Please authenticate to proceed',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: AppColors.black),
        )),
      ],
      firstLowerChildren: <Widget>[
        BottomButton(
          enabled: pros.settings.authMethodIsNativeSecurity,
          label: 'Unlock',
          onPressed: () async => submit(),
        )
      ],
    );
  }

  Future<void> submit() async {
    final LocalAuthApi localAuthApi = LocalAuthApi();
    streams.app.auth.authenticating.add(true);
    final bool validate = await localAuthApi.authenticate(
        skip: devFlags.contains(DevFlag.skipPin));
    streams.app.auth.authenticating.add(false);
    if (await services.password.lockout.handleVerificationAttempt(validate)) {
      services.cipher.loginTime();
      streams.app.auth.verify.add(true);
      (data['onSuccess'] ?? () {})();
    } else {
      if (localAuthApi.reason == AuthenticationResult.error) {
        streams.app.behavior.snack.add(Snack(
          message: 'Unknown login error: please set a pin on the device.',
        ));
      } else if (localAuthApi.reason == AuthenticationResult.failure) {
        streams.app.behavior.snack.add(Snack(
          message: 'Unknown login error: please try again.',
        ));
      }
    }
  }
}
