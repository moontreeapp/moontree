import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';

class ConnectionLight extends StatefulWidget {
  ConnectionLight({Key? key}) : super(key: key);

  @override
  _ConnectionLightState createState() => _ConnectionLightState();
}

class _ConnectionLightState extends State<ConnectionLight>
    with TickerProviderStateMixin, AnimationEagerListenerMixin {
  List<StreamSubscription> listeners = [];
  bool connected = false;
  Color connectedColor = Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
    listeners
        .add(streams.client.connected.listen((bool value) => value != connected
            ? setState(() {
                connected = value;
                connectedColor = value ? Color(0xFF4CAF50) : Color(0xFFF44336);
              })
            : () {/*do nothing*/}));
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          splashRadius: 24,
          padding: EdgeInsets.zero,
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            streams.app.verify.add(false);
            streams.app.xlead.add(true);
            Navigator.of(components.navigator.routeContext!)
                .pushNamed('/settings/network');
          },
          icon: ColorFiltered(
              colorFilter: ColorFilter.mode(connectedColor, BlendMode.srcATop),
              child: Image(image: AssetImage("assets/status/center.png"))),
        ),
      ],
    );
  }
}
