import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/pages/security/backup/types.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/services/wallet.dart'
    show populateWalletsWithSensitives;
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/utils/data.dart';
import 'package:ravencoin_front/utils/extensions.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class VerifySeed extends StatefulWidget {
  final dynamic data;
  const VerifySeed({this.data}) : super();

  @override
  _VerifySeedState createState() => _VerifySeedState();
}

class _VerifySeedState extends State<VerifySeed> {
  late Map<String, dynamic> data = {};
  bool validated = true;
  late double buttonWidth;
  late List<String> secret;
  late Map<int, SecretWord> shuffled;
  int click = 0;
  Map<int, SecretWord> clicks = {};

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
    secret = data['secret']!;
    shuffled = data['shuffled']!;
    buttonWidth = (MediaQuery.of(context).size.width - (17 + 17 + 16 + 16)) / 3;
    //print(1 - (48 + 48 + 16 + 8 + 8 + 72 + 56).ofAppHeight);
    return WillPopScope(
        onWillPop: () async => false,
        child: BackdropLayers(
            back: BlankBack(), front: FrontCurve(child: body())));
  }

  Widget body() => Stack(children: [
        components.page.form(
          context,
          columnWidgets: <Widget>[
            instructions,
            warning,
            if (smallScreen) words
          ],
          buttons: [submitButton],
        ),
        if (!smallScreen) wordsInStack
      ]);

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

  Widget get wordsInStack => Container(
      height: (1 - 72.ofAppHeight).ofAppHeight,
      alignment: Alignment.center,
      child: words);

  Widget get words => Container(
      height: 272 * (smallScreen ? .8 : 1),
      padding: (smallScreen ? null : EdgeInsets.only(left: 16, right: 16)),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        for (var x in [0, 3, 6, 9])
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            for (var i in [1, 2, 3])
              components.buttons.wordButton(context,
                  width: buttonWidth,
                  chosen: shuffled[(i + x) - 1]!.chosen != null,
                  label: shuffled[(i + x) - 1]!.word, onPressed: () {
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
      ]));

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
            await populateWalletsWithSensitives();
          }
          streams.app.setting.add(null);
          streams.app.fling.add(false);
          streams.app.lead.add(LeadIcon.pass);
          try {
            Navigator.of(context).popUntil(ModalRoute.withName('/home'));
          } catch (e) {
            print('home not found');
            Navigator.of(context).pushReplacementNamed('/home');
          }
          if (services.tutorial.missing.isEmpty) {
            streams.app.snack
                .add(Snack(message: 'Successfully Verified Backup'));
          }
          streams.app.wallet.refresh.add(true);
        },
      );
}
