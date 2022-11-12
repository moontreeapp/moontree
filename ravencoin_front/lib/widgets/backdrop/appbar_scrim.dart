import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/components/components.dart';

class AppBarScrim extends StatefulWidget {
  const AppBarScrim({Key? key}) : super(key: key);

  @override
  State<AppBarScrim> createState() => _AppBarScrimState();
}

class _AppBarScrimState extends State<AppBarScrim> {
  late List listeners = [];
  final Duration waitForSheetDrop = Duration(milliseconds: 10);
  bool? applyScrim = false;

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.scrim.listen((bool? value) async {
      if (value == null) {
        setState(() => applyScrim = null);
      }
      if (applyScrim == true && value == false) {
        await Future.delayed(waitForSheetDrop);
        setState(() => applyScrim = value);
      }
      if (applyScrim == false && value == true) {
        setState(() => applyScrim = value);
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
        Navigator.of(components.navigator.routeContext!)
            .popUntil(ModalRoute.withName('/home'));
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
