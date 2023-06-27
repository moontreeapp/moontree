import 'package:client_back/streams/app.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/infrastructure/services/wallet.dart'
    show populateWalletsWithSensitives;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/pages/backup/types.dart';
import 'package:client_front/presentation/services/services.dart' show sail;
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/theme/colors.dart';

class VerifySeed extends StatefulWidget {
  final dynamic data;
  const VerifySeed({Key? key, this.data}) : super(key: key);

  @override
  _VerifySeedState createState() => _VerifySeedState();
}

class _VerifySeedState extends State<VerifySeed> {
  late Map<String, dynamic> data = <String, dynamic>{};
  bool validated = true;
  late double buttonWidth;
  late List<String> secret;
  late Map<int, SecretWord> shuffled;
  int click = 0;
  Map<int, SecretWord> clicks = <int, SecretWord>{};
  bool clicked = false;

  @override
  void initState() {
    FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    // we used to do the shuffling of the words here, but now that it is a
    // future we moved that to show.dart and pass them in as arguments.
    super.initState();
  }

  @override
  void dispose() {
    FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    super.dispose();
  }

  bool get smallScreen => MediaQuery.of(context).size.height < 640;

  Future<List<String>> get getSecret async =>
      (await Current.wallet.secret(Current.wallet.cipher!)).split(' ');

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    secret = data['secret']! as List<String>;
    shuffled = <int, SecretWord>{
      for (Tuple2<int, SecretWord> s
          in (data['shuffled']! as List).enumeratedTuple())
        s.item1: s.item2
    };

    buttonWidth = (MediaQuery.of(context).size.width - (17 + 17 + 16 + 16)) / 3;
    //print(1 - (48 + 48 + 16 + 8 + 8 + 72 + 56).ofAppHeight);

    return Stack(children: <Widget>[
      PageStructure(
        children: <Widget>[
          GestureDetector(
              onDoubleTap: () async => clicked && click == 3
                  ? await proceed(skipped: true)
                  : clicked = true,
              child: Container(
                  height: 48,
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Please tap your words in the correct order.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: AppColors.black),
                  ))),
          Container(height: 48),
          if (smallScreen) words
        ],
        firstLowerChildren: <Widget>[
          BottomButton(
            enabled: checkOrder(),
            label: 'Verify',
            onPressed: proceed,
          )
        ],
      ),
      if (!smallScreen)
        Container(
            height: (1 - 72.ofAppHeight).ofAppHeight,
            alignment: Alignment.center,
            child: words)
    ]);
  }

  Widget get words => Container(
      height: 272 * (smallScreen ? .8 : 1),
      padding: smallScreen ? null : const EdgeInsets.only(left: 16, right: 16),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for (int x in <int>[0, 3, 6, 9])
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    for (int i in <int>[1, 2, 3])
                      components.buttons.wordButton(
                        context,
                        width: buttonWidth,
                        chosen: shuffled[(i + x) - 1]!.chosen != null,
                        label: shuffled[(i + x) - 1]!.word,
                        onPressed: () {
                          if (click == 0) {
                            click = [
                              for (SecretWord word in shuffled.values)
                                word.chosen ?? 0
                            ].max;
                          }
                          if (click < 13) {
                            final int clicked = (i + x) - 1;
                            if (shuffled[clicked]!.chosen == click) {
                              shuffled[clicked]!.chosen = null;
                              click--;
                            } else if (shuffled[clicked]!.chosen == null) {
                              click++;
                              shuffled[clicked]!.chosen = click;
                            } else if ((shuffled[clicked]?.chosen ?? 13) <
                                click) {
                              int undo = shuffled[clicked]!.chosen!;
                              for (final c in range(12)) {
                                if ((shuffled[c]?.chosen ?? 13) >= undo) {
                                  shuffled[c]!.chosen = null;
                                }
                              }
                              click = undo - 1;
                            }
                          }
                          setState(() {});
                        },
                        number: shuffled[(i + x) - 1]!.chosen,
                      )
                  ]),
          ]));

  bool checkOrder() {
    for (final SecretWord secretWord in shuffled.values) {
      if (secretWord.chosen == null) {
        return false;
      }
      if (!secretWord.correct &&
          secretWord.word != secret[secretWord.chosen! - 1]) {
        return false;
      }
    }
    return true;
  }

  Future<void> proceed({bool skipped = false}) async {
    if (Current.wallet is LeaderWallet) {
      await services.wallet.leader.backedUp(Current.wallet as LeaderWallet);
      await populateWalletsWithSensitives();
    }
    sail.home();
    Future.delayed(Duration(seconds: 1))
        .then((value) => components.cubits.tutorial.load());
    //if (components.cubits.tutorial.isEmpty) {
    //  if (skipped) {
    //    streams.app.behavior.snack.add(Snack(message: 'Successfully Skipped Backup'));
    //  } else {
    //    streams.app.behavior.snack.add(Snack(message: 'Successfully Verified Backup'));
    //  }
    //}
    streams.app.behavior.snack
        .add(Snack(message: 'Successfully Verified Backup'));
    streams.app.wallet.refresh.add(true);
  }
}
