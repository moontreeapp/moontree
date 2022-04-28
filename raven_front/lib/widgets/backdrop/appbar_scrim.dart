import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';

class AppBarScrim extends StatefulWidget {
  const AppBarScrim({Key? key}) : super(key: key);

  @override
  State<AppBarScrim> createState() => _AppBarScrimState();
}

class _AppBarScrimState extends State<AppBarScrim> {
  late List listeners = [];
  final Duration waitForSheetDrop = Duration(milliseconds: 50);
  bool applyScrim = false;

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.scrim.listen((bool value) async {
      if (applyScrim && !value) {
        await Future.delayed(waitForSheetDrop);
        setState(() {
          applyScrim = value;
        });
      }
      if (!applyScrim && value) {
        setState(() {
          applyScrim = value;
        });
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
    return GestureDetector(
        onTap: () async {
          Navigator.of(components.navigator.routeContext!).pop();
          streams.app.scrim.add(false);
        },
        child: AnimatedContainer(
          duration: waitForSheetDrop,
          color: applyScrim ? Colors.black38 : Colors.transparent,
          height: applyScrim ? 56 : 0,
        ));
  }
}
