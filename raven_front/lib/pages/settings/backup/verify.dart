import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/widgets/widgets.dart';

class SecretWord {
  String word;
  int order;
  int? chosenOrder;
  SecretWord(this.word, this.order);

  void set chosen(int? value) => chosenOrder = value;
  int? get chosen => chosenOrder;
  bool get correct => order + 1 == chosenOrder;

  @override
  String toString() => 'SecretWord($word, $order, $chosenOrder)';
}

class VerifySeed extends StatefulWidget {
  final dynamic data;
  const VerifySeed({this.data}) : super();

  @override
  _VerifySeedState createState() => _VerifySeedState();
}

class _VerifySeedState extends State<VerifySeed> {
  bool validated = true;
  late double buttonWidth;
  late List<String> secret;
  late Map<int, SecretWord> shuffled;
  int click = 0;
  Map<int, SecretWord> clicks = {};

  @override
  void initState() {
    secret = Current.wallet.secret(Current.wallet.cipher!).split(' ');
    var shuffledList = [
      for (var s in secret.enumerated()) SecretWord(s[1], s[0])
    ];
    shuffledList.shuffle();
    shuffled = {for (var s in shuffledList.enumerated()) s[0]: s[1]};
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    buttonWidth = (MediaQuery.of(context).size.width - (17 + 17 + 16 + 16)) / 3;
    return BackdropLayers(
        back: BlankBack(),
        front: FrontCurve(
            child: services.password.required && !streams.app.verify.value
                ? VerifyPassword(parentState: this)
                : body()));
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
      alignment: Alignment.topCenter,
      child: Text(
        'Please tap your words in the correct order.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.black),
      ));

  Widget get warning => Container(
        height: 48,
        //alignment: Alignment.topCenter,
      );

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
                              chosen: shuffled[(i + x) - 1]!.chosen != null,
                              label: shuffled[(i + x) - 1]!.word,
                              onPressed: () {
                            if (click < 13) {
                              var clicked = (i + x) - 1;
                              if (shuffled[clicked]!.chosen == click) {
                                shuffled[clicked]!.chosen = null;
                                click--;
                              } else if (shuffled[clicked]!.chosen == null) {
                                click++;
                                shuffled[clicked]!.chosen = click;
                              }
                            }
                            setState(() {});
                          }, number: shuffled[(i + x) - 1]!.chosen)
                      ]),
              ])));

  bool checkOrder() {
    for (var secretWord in shuffled.values) {
      if (secretWord.chosen == null) return false;
      if (!secretWord.correct &&
          secretWord.word != secret[secretWord.chosen! - 1]) return false;
    }
    return true;
  }

  Widget get submitButton => components.buttons.actionButton(
        context,
        enabled: checkOrder(),
        label: 'Verify',
        onPressed: () async {
          if (Current.wallet is LeaderWallet) {
            await services.wallet.leader
                .backedUp(Current.wallet as LeaderWallet);
          }
          Navigator.popUntil(context, ModalRoute.withName('/home'));
          streams.app.snack.add(Snack(message: 'Successfully Verified Backup'));
        },
      );
}
