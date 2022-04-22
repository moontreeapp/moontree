import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/client.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';

class ConnectionLight extends StatefulWidget {
  ConnectionLight({Key? key}) : super(key: key);

  @override
  _ConnectionLightState createState() => _ConnectionLightState();
}

class _ConnectionLightState extends State<ConnectionLight> {
  List<StreamSubscription> listeners = [];
  ConnectionStatus connected = ConnectionStatus.disconnected;
  Color connectedColor = AppColors.error;

  Map<ConnectionStatus, Color> connectionColor = {
    ConnectionStatus.connected: AppColors.success,
    ConnectionStatus.connecting: AppColors.yellow,
    ConnectionStatus.disconnected: AppColors.error,
  };

  @override
  void initState() {
    super.initState();
    listeners.add(streams.client.connected
        .listen((ConnectionStatus value) => value != connected
            ? setState(() {
                connected = value;
                connectedColor = connectionColor[value]!;
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
            if (streams.app.page.value != 'Login') {
              ScaffoldMessenger.of(context).clearSnackBars();
              streams.app.verify.add(false);
              streams.app.xlead.add(true);
              Navigator.of(components.navigator.routeContext!)
                  .pushNamed('/settings/network');
            }
          },
          icon: ColorFiltered(
              colorFilter: ColorFilter.mode(connectedColor, BlendMode.srcATop),
              child: SvgPicture.asset('assets/status/icon.svg')),
        ),
      ],
    );
  }
}
