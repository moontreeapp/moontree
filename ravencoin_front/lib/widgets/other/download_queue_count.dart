import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class DownloadQueueCount extends StatefulWidget {
  final dynamic data;
  const DownloadQueueCount({this.data}) : super();

  @override
  _DownloadQueueCount createState() => _DownloadQueueCount();
}

class _DownloadQueueCount extends State<DownloadQueueCount> {
  List<StreamSubscription> listeners = [];

  @override
  void initState() {
    super.initState();
    listeners.add(
        streams.client.queue.listen((bool queueChanged) => setState(() {})));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            'download queue count: '
            '${services.download.queue.addresses.length + services.download.queue.transactions.length + services.download.queue.dangling.length}',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Text('${services.download.queue.transactions.length} transactions'),
          Text('${services.download.queue.addresses.length} addresses'),
          Text('${services.download.queue.dangling.length} dangling'),
        ],
      ));
}
