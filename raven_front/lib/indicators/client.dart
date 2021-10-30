import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven/raven.dart';

class ClientIndicator extends StatefulWidget {
  const ClientIndicator() : super();

  @override
  _ClientIndicatorState createState() => _ClientIndicatorState();
}

class _ClientIndicatorState extends State<ClientIndicator> {
  List<StreamSubscription> listeners = [];
  String? lastestValue;
  bool active = false;

  @override
  void initState() {
    super.initState();
    // we can move a wallet from one account to another
    listeners.add(services.busy.client.stream.listen((value) {
      if (value == null) {
        setState(() {
          lastestValue = value;
          active = false;
        });
      } else {
        setState(() {
          lastestValue = value;
          active = true;
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
    var icon;
    var status;
    var message;
    if (active) {
      icon = Icon(Icons.swap_vert_rounded);
      status = 'Active';
      message = lastestValue;
    } else {
      icon =
          Icon(Icons.swap_vert_rounded, color: Theme.of(context).disabledColor);
      status = 'Idle';
      message =
          'This is a visual indication of your connection to the Ravencoin Electrum Server.';
    }
    return IconButton(
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                title: Text('Connection'),
                content: Text('$message \n\n Status: $status'))),
        icon: icon);
  }
}
