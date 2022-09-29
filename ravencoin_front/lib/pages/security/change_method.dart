import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class ChangeLoginMethod extends StatefulWidget {
  @override
  _ChangeLoginMethodState createState() => _ChangeLoginMethodState();
}

class _ChangeLoginMethodState extends State<ChangeLoginMethod> {
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
    streams.app.verify.add(false);
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
  Widget build(BuildContext context) => BackdropLayers(
      back: BlankBack(),
      front: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: FrontCurve(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        left: 0, right: 16, top: 24, bottom: 16),
                    child: Container(
                        alignment: Alignment.topLeft,
                        child: AuthenticationMethodChoice())),
                if (!pros.settings.authMethodIsNativeSecurity)
                  components.containers
                      .navBar(context, child: Row(children: [changeButton]))
              ]))));

  Widget get changeButton => components.buttons.actionButton(
        context,
        enabled: true,
        label: 'Change Password',
        focusNode: buttonFocus,
        disabledIcon: Icon(Icons.lock_rounded, color: AppColors.black38),
        link: '/security/password/change',
      );
}
