import 'package:flutter/material.dart';

import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

class ResyncChoice extends StatefulWidget {
  final dynamic data;
  const ResyncChoice({this.data}) : super();

  @override
  _ResyncChoice createState() => _ResyncChoice();
}

class _ResyncChoice extends State<ResyncChoice> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('Resync Blockchain Data',
            style: Theme.of(context).textTheme.bodyLarge),
        Text(
          'Clears database of transaction history and holdings, and redownloads it all.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Row(children: <Widget>[
          components.buttons.actionButtonSoft(
            context,
            enabled: true,
            label: 'Resync Now',
            onPressed: () async {
              //Navigator.of(context).popUntil(ModalRoute.withName('/home'));
              streams.app.behavior.snack
                  .add(Snack(message: 'resyncing, please wait...'));
              await services.client.resetMemoryAndConnection(
                  keepTx: false, keepBalances: false, keepAddresses: false);
            },
          )
        ])
      ]);
}
