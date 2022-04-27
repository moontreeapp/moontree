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

class _ConnectionLightState extends State<ConnectionLight>
    with SingleTickerProviderStateMixin {
  List<StreamSubscription> listeners = [];
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;
  Color connectionStatusColor = AppColors.error;
  bool connectionBusy = false;
  late DateTime startTime;
  static const duration = 1000;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: duration),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(-1, 0),
    end: const Offset(0, 0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ));

  Map<ConnectionStatus, Color> connectionColor = {
    ConnectionStatus.connected: AppColors.success,
    ConnectionStatus.connecting: AppColors.yellow,
    ConnectionStatus.disconnected: AppColors.error,
  };

  @override
  void initState() {
    super.initState();
    listeners.add(streams.client.connected.listen((ConnectionStatus value) {
      if (value != connectionStatus) {
        setState(() {
          connectionStatus = value;
          connectionStatusColor = connectionColor[value]!;
        });
      }
    }));
    listeners.add(streams.client.busy.listen((bool value) async {
      if (!connectionBusy && value) {
        startTime = DateTime.now();
        setState(() => connectionBusy = value);
      } else if (connectionBusy && !value) {
        var waited = DateTime.now().difference(startTime).inMilliseconds;
        var wait =
            ((duration * 2) - (waited % (duration * 2))) % (duration * 2);
        await Future.delayed(Duration(milliseconds: wait));
        if (streams.client.busy.value == value) {
          setState(() {
            connectionBusy = value;
            //_controller.reset();
          });
        }
      }
    }));
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var icon = ColorFiltered(
        colorFilter: ColorFilter.mode(connectionStatusColor, BlendMode.srcATop),
        child: SvgPicture.asset('assets/status/icon.svg'));
    return connectionBusy
        ? GestureDetector(
            onTap: () => streams.client.busy.add(false),
            child: SlideTransition(
              position: _offsetAnimation,
              child: icon,
            ))
        : IconButton(
            splashRadius: 24,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (streams.app.page.value != 'Login') {
                ScaffoldMessenger.of(context).clearSnackBars();
                if (services.cipher.canAskForPasswordNow) {
                  streams.app.verify.add(false);
                }
                streams.app.xlead.add(true);
                Navigator.of(components.navigator.routeContext!)
                    .pushNamed('/settings/network');
              }
            },
            icon: icon,
          );
  }
}
