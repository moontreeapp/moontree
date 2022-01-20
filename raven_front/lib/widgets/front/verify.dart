import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';

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

  Widget body() {
    var existingPasswordField = TextField(
      autocorrect: false,
      enabled: services.password.required ? true : false,
      controller: existingPassword,
      obscureText: !existingPasswordVisible,
      textInputAction: TextInputAction.next,
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'Current Password',
        helperText: existingPassword.text != '' && verify() ? 'sucess!' : null,
        errorText: existingPassword.text != '' && !verify() ? used() : null,
        suffixIcon: IconButton(
          icon: Icon(
              existingPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Color(0x99000000)),
          onPressed: () => setState(() {
            existingPasswordVisible = !existingPasswordVisible;
          }),
        ),
      ),
      onChanged: (String value) {
        if (verify()) {
          setState(() {});
        }
        // don't show red
        //setState(() {});
      },
      onEditingComplete: () => verify(),
    );
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            existingPasswordField,
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
    var enabled = verify();
    return Container(
        height: 40,
        child: OutlinedButton.icon(
            onPressed: enabled
                ? () {
                    streams.app.verify.add(true);
                    widget.parentState?.setState(() {});
                  }
                : () {},
            icon: Icon(
              Icons.login,
              color: enabled ? null : Color(0x61000000),
            ),
            label: Text(
              'Submit'.toUpperCase(),
              style: enabled
                  ? Theme.of(context).navBarButton
                  : Theme.of(context).navBarButtonDisabled,
            ),
            style: components.styles.buttons.bottom(
              context,
              disabled: !enabled,
            )));
  }

  bool verify() =>
      services.password.validate.password(existingPassword.text) &&
      services.password.validate.previouslyUsed(existingPassword.text) == 0;

  String used() =>
      {
        null: 'unrecognized',
        0: 'current password',
        1: 'prior password',
        2: 'password before last',
      }[services.password.validate.previouslyUsed(existingPassword.text)] ??
      'has been used before';
}
