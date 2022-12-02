import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/widgets/top/connection.dart';
import 'package:ravencoin_front/widgets/other/speech_bubble.dart';
import 'package:ravencoin_front/widgets/other/other.dart';

class TutorialLayer extends StatefulWidget {
  const TutorialLayer({Key? key}) : super(key: key);

  @override
  _TutorialLayerState createState() => _TutorialLayerState();
}

class _TutorialLayerState extends State<TutorialLayer> {
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  Color scrimColor = Colors.transparent;
  HitTestBehavior? behavior = null;
  double? height = 0;
  void Function()? onEnd = null;
  void Function()? onTap = null;

  @override
  void initState() {
    super.initState();
    onEnd = () => setState(() => height = 0);
    listeners.add(streams.app.tutorial.listen((TutorialStatus? value) async {
      if (value != null) {
        activateScrim();
      }
    }));
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: Duration(milliseconds: 100),
        onEnd: onEnd,
        height: height,
        color: scrimColor,
        child: GestureDetector(
          onTap: onTap,
          behavior: behavior,
          child: TutorialContent(tutorial: streams.app.tutorial.value),
        ),
      );

  void activateScrim() {
    setState(() {
      scrimColor = AppColors.scrim;
      behavior = HitTestBehavior.opaque;
      height = null;
      onEnd = null;
      onTap = removeScrim;
    });
  }

  void removeScrim() {
    streams.app.tutorial.add(null);
    setState(() {
      scrimColor = Colors.transparent;
      behavior = null;
      onEnd = () => setState(() => height = 0);
      onTap = null;
    });
  }
}

class TutorialContent extends StatelessWidget {
  const TutorialContent({Key? key, this.tutorial}) : super(key: key);

  final TutorialStatus? tutorial;

  @override
  Widget build(BuildContext context) => IgnorePointer(
      child: tutorial == TutorialStatus.blockchain
          ? Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                  preferredSize: Size.fromHeight(50),
                  child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      actions: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: ConnectionLight()),
                        SizedBox(width: 6),
                        Container(width: 40),
                        SizedBox(width: 8),
                      ])),
              body: Container(
                alignment: Alignment.topRight,
                padding: EdgeInsets.only(top: 1, right: 40),
                child: SpeechBubble(
                  nipOffCenter: 86,
                  child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Text('Tap to switch Blockchains',
                        style: Theme.of(context).textTheme.bodyText1),
                  ]),
                ),
              ))
          : Container());

  //services.tutorial.clear();
  //if (services.tutorial.missing.isNotEmpty) {
  //  WidgetsBinding.instance.addPostFrameCallback((_) async {
  //    await showTutorials();
  //  });
  //}

  //Future showTutorials() async {
  //  for (var tutorial in services.tutorial.missing) {
  //    streams.app.tutorial.add(true);
  //    services.tutorial.complete(tutorial);
  //    await showDialog(
  //        context: context,
  //        builder: (BuildContext context) {
  //          streams.app.scrim.add(true);
  //          return AlertDialog(
  //              title: Text('Password Not Recognized'),
  //              content: Text(
  //                  'Password does not match the password used at the time of encryption.'));
  //        }).then((value) => streams.app.scrim.add(false));
  //  }
  //}
}
