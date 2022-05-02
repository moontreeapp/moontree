import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/client.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';

class ActivityLight extends StatefulWidget {
  ActivityLight({Key? key}) : super(key: key);

  @override
  _ActivityLightState createState() => _ActivityLightState();
}

class _ActivityLightState extends State<ActivityLight>
    with TickerProviderStateMixin {
  List<StreamSubscription> listeners = [];
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;
  Color connectionStatusColor = AppColors.error;
  bool connectionBusy = false;

  @override
  void initState() {
    super.initState();

    listeners.add(streams.client.busy.listen((bool value) async {
      if (!connectionBusy && value) {
        setState(() => connectionBusy = value);
      } else if (connectionBusy && !value) {
        // todo wait til a good time to stop
        setState(() => connectionBusy = value);
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ActivityMessage activityMessage = streams.client.activity.value;
    return connectionBusy
        ? GestureDetector(
            onTap: () => components.message.giveChoices(
              context,
              title: activityMessage.title,
              content: activityMessage.message,
              behaviors: {
                'ok': () {
                  Navigator.of(context).pop();
                },
              },
            ),
            child: Container(
                width: 36,
                alignment: Alignment.centerLeft,
                child: Lottie.asset(
                  'assets/spinner/moontree_spinner_v2_002_1_recolored.json',
                  animate: true,
                  repeat: true,
                  width: 56 / 2,
                  height: 56 / 2,
                  alignment: Alignment.centerLeft,
                )),
          )
        : Container();
  }
}
