import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven/raven.dart';

class ProcessIndicator extends StatefulWidget {
  const ProcessIndicator() : super();

  @override
  _ProcessIndicatorState createState() => _ProcessIndicatorState();
}

class _ProcessIndicatorState extends State<ProcessIndicator> {
  List<StreamSubscription> listeners = [];
  String? lastestValue;
  bool active = false;

  @override
  void initState() {
    super.initState();
    // we can move a wallet from one account to another
    listeners.add(services.busy.process.stream.listen((value) async {
      if (value == null) {
        await Future.delayed(Duration(seconds: 2));
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
      icon = Icon(Icons.circle, size: 10);
      status = 'Active';
      message = lastestValue;
    } else {
      icon =
          Icon(Icons.circle, size: 10, color: Theme.of(context).disabledColor);
      status = 'Idle';
      message =
          'This is a visual indication of background activity such as encryption.';
    }
    return IconButton(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(0),
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                title: Text('Connection'),
                content: Text('$message \n\n Status: $status'))),
        icon: icon);
  }
}
