import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/widgets.dart';

class VerifyPassword extends StatefulWidget {
  final State? parentState;

  VerifyPassword({Key? key, this.parentState}) : super(key: key);

  @override
  _VerifyPasswordState createState() => _VerifyPasswordState();
}

class _VerifyPasswordState extends State<VerifyPassword> {
  var existingPassword = TextEditingController();
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
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: body(),
      );

  Widget body() => CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
          child: Container(height: (MediaQuery.of(context).size.height) / 3),
        ),
        SliverToBoxAdapter(
          child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
              height: 70,
              child: existingPasswordField),
        ),
        SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 100),
                  KeyboardHidesWidget(
                      child: components.containers.navBar(context,
                          child: Row(children: [submitButton]))),
                ])),
      ]);

  Widget get existingPasswordField => TextField(
        focusNode: existingFocus,
        autocorrect: false,
        enabled: services.password.required ? true : false,
        controller: existingPassword,
        obscureText: !existingPasswordVisible,
        textInputAction: TextInputAction.next,
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
        onChanged: (String value) {
          if (verify()) {
            setState(() {});
          }
          setState(() {});
        },
        onEditingComplete: () {
          verify();
          submitFocus.requestFocus();
        },
      );

  Widget get submitButton => components.buttons.actionButton(
        context,
        focusNode: submitFocus,
        enabled: verify(),
        label: 'Submit',
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
