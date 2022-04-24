import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/widgets/widgets.dart';

class BackupNext extends StatefulWidget {
  final dynamic data;
  const BackupNext({this.data}) : super();

  @override
  _BackupNextState createState() => _BackupNextState();
}

class _BackupNextState extends State<BackupNext> {
  bool validated = true;
  bool warn = true;

  @override
  Widget build(BuildContext context) {
    return services.password.required && !streams.app.verify.value
        ? VerifyPassword(parentState: this, suffix: 'with backup process')
        : BackUpdropLayers();
  }
}

class BackupSeed extends StatelessWidget {
  const BackupSeed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
        back: BlankBack(),
        front: FrontCurve(
            child: components.page.form(
          context,
          columnWidgets: <Widget>[
            Intro(),
            Safe(),
          ],
          buttons: [ShowSeed()],
        )));
  }
}

class BackUpdropLayers extends StatelessWidget {
  const BackUpdropLayers({Key? key, this.warn = false}) : super(key: key);
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final buttonWidth =
        (MediaQuery.of(context).size.width - (17 + 17 + 16 + 16)) / 3;

    return BackdropLayers(
        back: BlankBack(),
        front: FrontCurve(
            child: components.page.form(
          context,
          columnWidgets: <Widget>[
            Instructions(),
            Warning(),
            Words(buttonWidth),
          ],
          buttons: [SubmitButton()],
        )));
  }
}

class Intro extends StatelessWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 48,
        alignment: Alignment.topCenter,
        child: Text(
          'Your wallet is valuable.\nPlease create a backup!',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .subtitle1!
              .copyWith(color: AppColors.black),
        ));
  }
}

class Safe extends StatelessWidget {
  const Safe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 48,
        alignment: Alignment.topCenter,
        child: Text(
          'You are about to backup your seed words.\nKeep it secret, keep it safe.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .subtitle1!
              .copyWith(color: AppColors.error),
        ));
  }
}

class Instructions extends StatelessWidget {
  const Instructions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 48,
        alignment: Alignment.topCenter,
        child: Text(
          'Please backup your wallet by writing down these words on a piece of paper.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .subtitle1!
              .copyWith(color: AppColors.black),
        ));
  }
}

class Warning extends StatelessWidget {
  const Warning({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 48,
        alignment: Alignment.topCenter,
        child: Text(
          'You will need these words for recovery.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .subtitle1!
              .copyWith(color: AppColors.error),
        ));
  }
}

class Words extends StatelessWidget {
  const Words(this.buttonWidth, {Key? key}) : super(key: key);
  final double buttonWidth;
  @override
  Widget build(BuildContext context) {
    late List<String> secret =
        Current.wallet.secret(Current.wallet.cipher!).split(' ');
    return Container(
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
  }
}

class ShowSeed extends StatelessWidget {
  const ShowSeed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return components.buttons.actionButton(
      context,
      enabled: true,
      label: 'Show Seed',
      currentLink: "/security/backup",
      link: '/security/backupNext',
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return components.buttons.actionButton(
      context,
      enabled: true,
      label: 'Next',
      currentLink: '/security/backupNext',
      link: '/security/backupConfirm',
    );
  }
}
