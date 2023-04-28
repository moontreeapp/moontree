import 'dart:async';
import 'dart:io' show Platform;
import 'package:client_front/presentation/services/services.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:moontree_utils/moontree_utils.dart';
//import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/infrastructure/services/wallet.dart'
    show getSecret;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/pages/backup/types.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

class BackupSeed extends StatefulWidget {
  final dynamic data;
  const BackupSeed({Key? key, this.data}) : super(key: key);

  @override
  _BackupSeedState createState() => _BackupSeedState();
}

class _BackupSeedState extends State<BackupSeed>
    with SingleTickerProviderStateMixin {
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  bool validated = true;
  bool warn = true;
  late double buttonWidth;
  late List<String> secret;

  //ScreenshotCallback screenshotCallback = ScreenshotCallback();

  /// from exploring animations - want to return to
  //late AnimationController controller;
  //late Animation<double> animation;
  //late Animation<double> curve;
  //Offset offset = Offset(0.0, -1.0);
  @override
  void initState() {
    super.initState();
    //streams.app.auth.verify.add(false);
    if (Platform.isAndroid) {
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    } else if (Platform.isIOS) {
      //screenshotCallback.addListener(() {
      //  // maybe we can repaint the screen real quick before the screenshot is taken
      //  // or display a message telling them to write it down...
      //  print('detect screenshot');
      //});
    }
    //listeners.add(streams.app.auth.verify.listen((value) {
    //  if (value == true) {
    //    setState(() {});
    //  }
    //}));
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    } else if (Platform.isIOS) {
      //screenshotCallback.dispose();
    }

    super.dispose();
  }

  bool get smallScreen => MediaQuery.of(context).size.height < 640;

  Future<List<String>> auth() async {
    if (/*services.password.askCondition*/ false) {
      ScaffoldMessenger.of(context).clearSnackBars();
      //produceBlockchainModal(context: components.routes.routeContext!);
      //components.cubits.bottomModalSheet.show(children: [
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white,
        builder: (context) => Container(
            height: screen.app.height / 2,
            width: screen.width,
            alignment: Alignment.center,
            child: VerifyAuthentication(
              buttonLabel: 'Show Seed',
              intro: Container(
                  //height: 48,
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Your wallet is valuable.\nPlease create a backup!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: AppColors.black),
                  )),
              auto: true,
              asLoginTime: true,
            )),
      );

      //]);
      components.cubits.title.update(editable: false);
    }
    return await getSecret;
  }

  @override
  Widget build(BuildContext context) {
    buttonWidth = (MediaQuery.of(context).size.width - (17 + 17 + 16 + 16)) / 3;
    //print(1 - (48 + 48 + 16 + 8 + 8 + 72 + 56).ofAppHeight);

    return FutureBuilder<List<String>>(
        future: getSecret,
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            secret = snapshot.data!;
            return
                //services.password.askCondition
                //    ? VerifyAuthentication(
                //        buttonLabel: 'Show Seed',
                //        intro: Container(
                //            //height: 48,
                //            alignment: Alignment.topCenter,
                //            child: Text(
                //              'Your wallet is valuable.\nPlease create a backup!',
                //              textAlign: TextAlign.center,
                //              style: Theme.of(context)
                //                  .textTheme
                //                  .subtitle1!
                //                  .copyWith(color: AppColors.black),
                //            )),
                //        auto: true,
                //        asLoginTime: true,
                //      )
                //    :
                Stack(children: [
              PageStructure(
                children: <Widget>[
                  BackupInstructions(),
                  BackupWarning(),
                  if (smallScreen) words
                ],
                firstLowerChildren: <Widget>[
                  BottomButton(
                    label: 'Verify Backup',
                    link: '/backup/verify',
                    arguments: () {
                      //secret = Current.wallet.secret(Current.wallet.cipher!).split(' ');
                      final List<SecretWord> shuffled = <SecretWord>[
                        for (Tuple2<int, String> s in secret.enumeratedTuple())
                          SecretWord(word: s.item2, order: s.item1)
                      ];
                      shuffled.shuffle();
                      return <String, dynamic>{
                        'secret': secret,
                        'shuffled': shuffled,
                      };
                    }(),
                  )
                ],
              ),
              if (!smallScreen)
                Container(
                    height: (1 - 72.ofAppHeight).ofAppHeight,
                    alignment: Alignment.center,
                    child: words)
            ]);
          } else {
            return const CircularProgressIndicator();
          }
        });
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
                      components.buttons.wordButton(context,
                          width: buttonWidth,
                          label: secret[(i + x) - 1],
                          onPressed: () {},
                          number: i + x)
                  ]),
          ]));
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

class BackupInstructions extends StatelessWidget {
  const BackupInstructions({super.key});
  @override
  Widget build(BuildContext context) => Container(
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
}

class BackupWarning extends StatelessWidget {
  const BackupWarning({super.key});
  @override
  Widget build(BuildContext context) => Container(
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
}
