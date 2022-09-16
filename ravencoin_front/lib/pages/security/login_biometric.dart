import 'package:flutter/material.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/auth.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class LoginBiometric extends StatefulWidget {
  @override
  _LoginBiometricState createState() => _LoginBiometricState();
}

class _LoginBiometricState extends State<LoginBiometric> {
  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() =>
      Container(alignment: Alignment.center, height: 120, child: bioButton);

  Widget get bioButton => components.buttons.actionButton(context,
          enabled: true, label: 'biometric login', onPressed: () async {
        final localAuthApi = LocalAuthApi();
        print(await localAuthApi.authenticate());
      });
}
