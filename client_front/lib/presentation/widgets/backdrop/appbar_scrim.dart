import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

class AppBarScrim extends StatefulWidget {
  const AppBarScrim({Key? key}) : super(key: key);

  @override
  State<AppBarScrim> createState() => _AppBarScrimState();
}

class _AppBarScrimState extends State<AppBarScrim> {
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  final Duration waitForSheetDrop = const Duration(milliseconds: 10);
  bool? applyScrim = false;

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.scrim.listen((bool? value) async {
      if (value == null) {
        setState(() => applyScrim = null);
      }
      if (applyScrim == true && value == false) {
        await Future<void>.delayed(waitForSheetDrop);
        setState(() => applyScrim = value);
      }
      if (applyScrim == false && value == true) {
        setState(() => applyScrim = value);
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
    return GestureDetector(
      onTap: () async {
        //Navigator.of(components.routes.routeContext!)
        //    .popUntil(ModalRoute.withName('/home'));
        Navigator.of(components.routes.routeContext!).pop();
        streams.app.scrim.add(false);
      },
      child: applyScrim != null
          ? AnimatedContainer(
              duration: waitForSheetDrop, // to make it look better, causes #604
              color: applyScrim == true ? Colors.black38 : Colors.transparent,
              height: applyScrim == true ? 56 : 0,
            )
          : Container(
              color: Colors.transparent,
              height: 0,
            ),
    );
  }
}
