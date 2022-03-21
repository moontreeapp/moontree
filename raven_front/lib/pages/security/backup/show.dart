import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/widgets/widgets.dart';

class BackupSeed extends StatefulWidget {
  final dynamic data;
  const BackupSeed({this.data}) : super();

  @override
  _BackupSeedState createState() => _BackupSeedState();
}

class _BackupSeedState extends State<BackupSeed> {
  bool validated = true;
  late double buttonWidth;
  late List<String> secret;

  @override
  Widget build(BuildContext context) {
    buttonWidth = (MediaQuery.of(context).size.width - (17 + 17 + 16 + 16)) / 3;
    secret = Current.wallet.secret(Current.wallet.cipher!).split(' ');
    return services.password.required && !streams.app.verify.value
        ? VerifyPassword(parentState: this)
        : body();
  }

  Widget body() => components.page.form(
        context,
        columnWidgets: <Widget>[
          instructions,
          warning,
          words,
        ],
        buttons: [submitButton],
      );

  Widget get instructions => Container(
      height: 48,
      child: Text(
        'Please backup your wallet by writing down these words on a piece of paper.',
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.black),
      ));

  Widget get warning => Container(
      height: 48,
      //alignment: Alignment.topCenter,
      child: Text(
        'You will need these words for recovery.',
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.error),
      ));

  Widget get words => Container(
      height: MediaQuery.of(context).size.height - 444,
      alignment: Alignment.bottomCenter,
      child: Container(
          height: 272,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var x in [0, 3, 6, 9])
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i in [1, 2, 3])
                          components.buttons.wordButton(context,
                              width: buttonWidth,
                              chosen: false,
                              label: secret[(i + x) - 1],
                              onPressed: () {},
                              number: i + x)
                      ]),
              ])));

  Widget get submitButton => components.buttons.actionButton(
        context,
        enabled: true,
        label: 'Next',
        link: '/security/backupConfirm',
      );
}
