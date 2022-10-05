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
  Widget build(BuildContext context) {
    final addresses = services.download.queue.addresses.length;
    final transactions = services.download.queue.transactions.length +
        services.download.queue.dangling.length;
    final both = addresses > 0 && transactions > 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'download queue: '
          '${addresses + transactions}',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        if (both)
          Text(
            '${transactions} transactions',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        if (both)
          Text(
            '${addresses} addresses',
            style: Theme.of(context).textTheme.subtitle1,
          ),
      ],
    );
  }
}
