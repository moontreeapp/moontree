import 'dart:io' show Platform;
import 'package:moontree_utils/moontree_utils.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
//import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/pages/security/backup/types.dart';
import 'package:ravencoin_front/services/wallet.dart' show getSecret;
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/utils/extensions.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class BackupSeed extends StatefulWidget {
  final dynamic data;
  const BackupSeed({Key? key, this.data}) : super(key: key);

  @override
  _BackupSeedState createState() => _BackupSeedState();
}

class _BackupSeedState extends State<BackupSeed>
    with SingleTickerProviderStateMixin {
  bool validated = true;
  bool warn = true;
  late double buttonWidth;
  late List<String> secret;
  TextEditingController password = TextEditingController();
  FocusNode existingFocus = FocusNode();
  FocusNode showFocus = FocusNode();
  bool failedAttempt = false;
  bool enabled = true;
  //ScreenshotCallback screenshotCallback = ScreenshotCallback();

  /// from exploring animations - want to return to
  //late AnimationController controller;
  //late Animation<double> animation;
  //late Animation<double> curve;
  //Offset offset = Offset(0.0, -1.0);
  @override
  void initState() {
    super.initState();
    streams.app.verify.add(false);
    if (Platform.isAndroid) {
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    } else if (Platform.isIOS) {
      //screenshotCallback.addListener(() {
      //  // maybe we can repaint the screen real quick before the screenshot is taken
      //  // or display a message telling them to write it down...
      //  print('detect screenshot');
      //});
    }

    /// from exploring animations - want to return to
    //controller = AnimationController(
    //    vsync: this, duration: const Duration(milliseconds: 2400));
    //animation = Tween(begin: 0.0, end: 1.0).animate(controller);
    //curve = CurvedAnimation(parent: animation, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    } else if (Platform.isIOS) {
      //screenshotCallback.dispose();
    }

    /// from exploring animations - want to return to
    //controller.dispose();
    password.dispose();
    existingFocus.dispose();
    showFocus.dispose();
    super.dispose();
  }

  bool get smallScreen => MediaQuery.of(context).size.height < 640;

  @override
  Widget build(BuildContext context) {
    buttonWidth = (MediaQuery.of(context).size.width - (17 + 17 + 16 + 16)) / 3;
    //print(1 - (48 + 48 + 16 + 8 + 8 + 72 + 56).ofAppHeight);
    return WillPopScope(
        onWillPop: () async => false,
        child: FutureBuilder<List<String>>(
            future: getSecret,
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.hasData) {
                secret = snapshot.data!;
                return services.password.askCondition
                    ? VerifyAuthentication(
                        parentState: this,
                        buttonLabel: 'Show Seed',
                        intro: intro,
                        safe: safe,
                        auto: true,
                        asLoginTime: true,
                      )
                    : body();
              } else {
                return const CircularProgressIndicator();
              }
            }));
  }

  Widget body() => BackdropLayers(
      back: const BlankBack(),
      front: FrontCurve(
          child: Stack(children: <Widget>[
        components.page.form(
          context,
          columnWidgets: <Widget>[
            _instructions,
            _warning,
            if (smallScreen) words,
          ],
          buttons: <Widget>[submitButton],
        ),
        if (!smallScreen) wordsInStack
      ])));

  /// from exploring animations - want to return to
  /// animate()
  //Widget animate(child) => SlideTransition(
  //    position: Tween<Offset>(
  //      begin: offset,
  //      end: Offset.zero,
  //    ).animate(curve),
  //    child: FadeTransition(opacity: animation, child: child));

  Widget get intro => Container(
      //height: 48,
      alignment: Alignment.topCenter,
      child: Text(
        'Your wallet is valuable.\nPlease create a backup!',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.black),
      ));

  Widget get safe => Container(
      //height: 48,
      alignment: Alignment.topCenter,
      child: Text(
        'You are about to backup your seed words.\nKeep it secret, keep it safe.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.error),
      ));

  Widget get _instructions => instructions(context);

  Widget get _warning => warning(context);

  Widget get wordsInStack => Container(
      height: (1 - 72.ofAppHeight).ofAppHeight,
      alignment: Alignment.center,
      child: words);

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
                      components.buttons.wordButton(context,
                          width: buttonWidth,
                          label: secret[(i + x) - 1],
                          onPressed: () {},
                          number: i + x)
                  ]),
          ]));

  Widget get submitButton => components.buttons.actionButton(
        context,
        label: 'Verify Backup',
        link: '/security/backupConfirm',
        arguments: () {
          //secret = Current.wallet.secret(Current.wallet.cipher!).split(' ');
          final List<SecretWord> shuffledList = <SecretWord>[
            for (Tuple2<int, String> s in secret.enumeratedTuple())
              SecretWord(word: s.item2, order: s.item1)
          ];
          shuffledList.shuffle();
          final Map<int, SecretWord> shuffled = <int, SecretWord>{
            for (Tuple2<int, SecretWord> s in shuffledList.enumeratedTuple())
              s.item1: s.item2
          };
          streams.app.lead.add(LeadIcon.back);
          return <String, dynamic>{
            'secret': secret,
            'shuffled': shuffled,
          };
        }(),

        /// from exploring animations - want to return to
        //onPressed: () async {
        //  // change animation...
        //  animation = Tween(begin: 1.0, end: 0.0).animate(controller);
        //  curve = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        //  offset = Offset(0.0, 0.5);
        //  controller.reset();
        //  controller.forward();
        //  // wait the approapriate amount of time for the animation to play
        //  await Future<void>.delayed(const Duration(milliseconds: 2400));
        //},
      );
}

typedef void OnWidgetSizeChange(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}

Widget instructions(BuildContext context) => Container(
    //height: 48,
    alignment: Alignment.topCenter,
    child: Text(
      'Please backup your wallet by writing down these words on a piece of paper.',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .subtitle1!
          .copyWith(color: AppColors.black),
    ));

Widget warning(BuildContext context) => Container(
    //height: 48,
    alignment: Alignment.topCenter,
    child: Text(
      'You will need these words for recovery.',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .subtitle1!
          .copyWith(color: AppColors.error),
    ));
