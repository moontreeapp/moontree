import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_front/components/components.dart';
import 'package:client_front/widgets/front/choices/download_activity.dart';

class ActivityLight extends StatefulWidget {
  const ActivityLight({Key? key}) : super(key: key);

  @override
  _ActivityLightState createState() => _ActivityLightState();
}

class _ActivityLightState extends State<ActivityLight>
    with TickerProviderStateMixin {
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  bool connectionBusy = false;
  ActivityMessage activityMessage = ActivityMessage();
  late String pageTitle = '';

  @override
  void initState() {
    super.initState();
    listeners.add(streams.client.activity.listen((ActivityMessage value) async {
      if (activityMessage != value) {
        setState(() => activityMessage = value);
      }
    }));
    listeners.add(streams.client.busy.listen((bool value) async {
      if (!connectionBusy && value) {
        setState(() => connectionBusy = value);
      } else if (connectionBusy && !value) {
        setState(() => connectionBusy = value);
      }
    }));
    listeners.add(streams.app.page.listen((String value) {
      if (value != pageTitle) {
        setState(() {
          pageTitle = value;
        });
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
  Widget build(BuildContext context) {
    return <String>['Login', 'Createlogin'].contains(pageTitle)
        ? Container()
        : connectionBusy
            ? GestureDetector(
                onTap: () => components.message.giveChoices(
                  components.navigator.routeContext!,
                  title: activityMessage.title ?? 'Network Activity',
                  content: activityMessage.message,
                  child: activityMessage.message == '' ||
                          activityMessage.message == null
                      ? (services.developer.advancedDeveloperMode == true
                          //? DownloadQueueCount()
                          ? const DownloadActivity()
                          : null)
                      : null,
                  behaviors: <String, void Function()>{
                    'ok': () {
                      Navigator.of(components.navigator.routeContext!).pop();
                    },
                  },
                ),
                child: Container(
                    width: 36,
                    alignment: Alignment.center,
                    child: Lottie.asset(
                      'assets/spinner/moontree_spinner_v2_002_1_recolored.json',
                      animate: true,
                      repeat: true,
                      width: 56 / 2,
                      height: 56 / 2,
                      alignment: Alignment.center,
                    )),
              )
            : Container();
  }
}
