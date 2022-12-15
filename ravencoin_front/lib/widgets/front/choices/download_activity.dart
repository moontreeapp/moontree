import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/client.dart';

class DownloadActivity extends StatefulWidget {
  final dynamic data;
  const DownloadActivity({this.data}) : super();

  @override
  _DownloadActivity createState() => _DownloadActivity();
}

class _DownloadActivity extends State<DownloadActivity> {
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  ActivityMessage message = ActivityMessage();

  @override
  void initState() {
    super.initState();
    listeners.add(
        streams.client.download.listen((ActivityMessage msg) => setState(() {
              message = msg;
            })));
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          message.message ?? 'Syncing...',
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ],
    );
  }
}
