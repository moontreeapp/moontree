import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_electrum/raven_electrum.dart';

import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_back/raven_back.dart';
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
    secret = Current.wallet.cipher != null
        ? Current.wallet.secret(Current.wallet.cipher!).split(' ')
        : ['unknown'];
    // testing duplicates
    //secret = secret.sublist(0, 10) + [secret.last] + [secret.last];
    //print(secret);
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
    return services.password.required && !streams.app.verify.value
        ? VerifyPassword(parentState: this)
        : body();
  }

  Widget body() => Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 0),
      child: CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(child: SizedBox(height: 6)),
        SliverToBoxAdapter(child: instructions),
        SliverToBoxAdapter(child: words),
        SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [submitButton]),
                  SizedBox(height: 40),
                ])),
      ]));

  Widget get instructions => Container(
      height: 48,
      child: Text(
        'Please backup your wallet by writing down these words on a piece of paper.',
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.black),
      ));

  Widget get words => Container(
      height:
          MediaQuery.of(context).size.height - 380, // centered between text...
      //392, // center of screen
      alignment: Alignment.bottomCenter,
      child: Container(
          height: 272,
          //color: Colors.grey,
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
                              print(clicked);
                              print(click);
                              print(shuffled[clicked]);
                              if (shuffled[clicked]!.chosen == click) {
                                shuffled[clicked]!.chosen = null;
                                click--;
                              } else if (shuffled[clicked]!.chosen == null) {
                                click++;
                                shuffled[clicked]!.chosen = click;
                              }
                              for (var y in shuffled.entries) print(y);
                            }
                            setState(() {});
                          }, number: shuffled[(i + x) - 1]!.chosen)
                      ]),
              ])));

  bool checkOrder() {
    for (var secretWord in shuffled.values) {
      print(secretWord.correct);
      if (secretWord.chosen == null) return false;
      if (!secretWord.correct &&
          secretWord.word != secret[secretWord.chosen! - 1]) return false;
    }
    return true;
  }

  Widget get submitButton => components.buttons.actionButton(
        context,
        enabled: checkOrder(),
        label: 'Next',
        onPressed: () {
          Navigator.popUntil(context, ModalRoute.withName('/home'));
          streams.app.snack.add(Snack(message: 'Successfully Created Backup'));
        },
      );
}
