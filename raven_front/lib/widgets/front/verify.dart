import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/theme/theme.dart';

class VerifyPassword extends StatefulWidget {
  final State? parentState;

  VerifyPassword({Key? key, this.parentState}) : super(key: key);

  @override
  _VerifyPasswordState createState() => _VerifyPasswordState();
}

class _VerifyPasswordState extends State<VerifyPassword> {
  var existingPassword = TextEditingController();
  bool existingPasswordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    existingPassword.dispose();
    super.dispose();
  }

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
          existingPasswordField,
          Row(children: [submitButton])
        ],
      ));

  Widget get existingPasswordField => TextField(
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
                color: AppColors.black60),
            onPressed: () => setState(() {
              existingPasswordVisible = !existingPasswordVisible;
            }),
          ),
        ),
        onChanged: (String value) {
          if (verify()) {
            setState(() {});
          }
          setState(() {});
        },
        onEditingComplete: () => verify(),
      );

  Widget get submitButton => components.buttons.actionButton(
        context,
        enabled: verify(),
        label: 'Submit',
        disabledIcon: Icon(Icons.login, color: AppColors.black38),
        icon: Icon(Icons.login),
        onPressed: () {
          streams.app.verify.add(true);
          widget.parentState?.setState(() {});
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
}
