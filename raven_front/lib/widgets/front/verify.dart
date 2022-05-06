import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/widgets.dart';

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
  TextEditingController existingPassword = TextEditingController();
  bool existingPasswordVisible = false;
  FocusNode existingFocus = FocusNode();
  FocusNode submitFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    existingPassword.dispose();
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
                existingPasswordField,
              ],
              buttons: [submitButton],
            ),
          )
          //)
          );

  Widget get existingPasswordField => TextField(
        focusNode: existingFocus,
        autocorrect: false,
        enabled: services.password.required ? true : false,
        controller: existingPassword,
        obscureText: !existingPasswordVisible,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textField(
          context,
          focusNode: existingFocus,
          labelText: 'Password',
          errorText: existingPassword.text != '' && !verify() ? used() : null,
          //suffixIcon: IconButton(
          //  icon: Icon(
          //      existingPasswordVisible
          //          ? Icons.visibility
          //          : Icons.visibility_off,
          //      color: AppColors.black60),
          //  onPressed: () => setState(() {
          //    existingPasswordVisible = !existingPasswordVisible;
          //  }),
          //),
        ),
        onChanged: (String value) {},
        onEditingComplete: () {
          if (verify()) {
            setState(() {});
          }
          setState(() {});
          //submitFocus.requestFocus();
          FocusScope.of(context).requestFocus(submitFocus);
        },
      );

  Widget get submitButton => components.buttons.actionButton(
        context,
        focusNode: submitFocus,
        enabled: verify(),
        label: widget.buttonLabel,
        onPressed: submitProceedure,
      );

  bool verify() =>
      services.password.validate.password(existingPassword.text); // &&
  //services.password.validate.previouslyUsed(existingPassword.text) == 0;

  void submitProceedure() {
    if (verify()) {
      streams.app.verify.add(true);
      widget.parentState?.setState(() {});
    } else {
      // add timer stuff
    }
  }

  String used() =>
      {
        null: 'unrecognized',
        //0: 'current password',
        //1: 'prior password',
        //2: 'password before last',
      }[services.password.validate.previouslyUsed(existingPassword.text)] ??
      //'has been used before';
      'unrecognized';
}
