import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class VerifyPassword extends StatefulWidget {
  final State? parentState;
  final String buttonLabel;
  final String? suffix;

  VerifyPassword({
    Key? key,
    this.parentState,
    this.buttonLabel = 'Submit',
    this.suffix,
  }) : super(key: key);

  @override
  _VerifyPasswordState createState() => _VerifyPasswordState();
}

class _VerifyPasswordState extends State<VerifyPassword> {
  TextEditingController password = TextEditingController();
  bool passwordVisible = false;
  FocusNode existingFocus = FocusNode();
  FocusNode submitFocus = FocusNode();
  bool failedAttempt = false;

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
  Widget build(BuildContext context) =>
      //GestureDetector(
      //onTap: () => FocusScope.of(context).unfocus(),
      //child:
      BackdropLayers(
          back: BlankBack(),
          front: FrontCurve(
            child: components.page.form(
              context,
              columnWidgets: <Widget>[
                Container(height: (MediaQuery.of(context).size.height) / 3),
                //Center(
                //    child: Text(
                //        'Please verify your password\nto proceed' +
                //            (widget.suffix != null ? ' ' + widget.suffix! : ''),
                //        textAlign: TextAlign.center,
                //        style: Theme.of(context).textTheme.bodyText1)),
                //SizedBox(height: 8),
                LockedOutTime(),
                passwordField,
              ],
              buttons: [submitButton],
            ),
          )
          //)
          );

  Widget get passwordField => TextField(
        focusNode: existingFocus,
        autocorrect: false,
        enabled: services.password.required ? true : false,
        controller: password,
        obscureText: !passwordVisible,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textField(
          context,
          focusNode: existingFocus,
          labelText: 'Password',
          errorText: password.text == '' &&
                  pros.settings.loginAttempts.length > 0 &&
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

  Widget get submitButton => components.buttons.actionButton(
        context,
        focusNode: submitFocus,
        enabled: password.text != '' && services.password.lockout.timePast(),
        label: widget.buttonLabel,
        onPressed: submitProceedure,
      );

  bool verify() => services.password.validate.password(password.text); // &&
  //services.password.validate.previouslyUsed(password.text) == 0;

  Future<void> submitProceedure() async {
    if (await services.password.lockout.handleVerificationAttempt(verify())) {
      streams.app.verify.add(true);
      widget.parentState?.setState(() {});
    } else {
      setState(() {
        failedAttempt = true;
        password.text = '';
      });
    }
  }

  String used() =>
      {
        null: 'unrecognized',
        //0: 'current password',
        //1: 'prior password',
        //2: 'password before last',
      }[services.password.validate.previouslyUsed(password.text)] ??
      //'has been used before';
      'unrecognized';
}
