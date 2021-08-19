import 'package:flutter/material.dart';
import 'package:raven_mobile/pages/receive.dart';
import 'package:raven_mobile/pages/send.dart';
import 'package:raven_mobile/pages/settings/settings.dart';
import 'package:raven_mobile/styles.dart';

BottomAppBar walletTradingButtons(context) => BottomAppBar(
    color: Colors.grey[300],
    child:
        ButtonBar(alignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
      IconButton(
          onPressed: () {/*to wallet*/},
          icon: Icon(Icons.account_balance_wallet_rounded,
              color: RavenColor().appBar)),
      IconButton(onPressed: () {/*to trading*/}, icon: Icon(Icons.swap_horiz))
    ]));

GestureDetector settingsButton(context) => GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Settings()),
      );
    },
    child: Icon(Icons.more_horiz));

IconButton backIconButton(context) =>
    IconButton(icon: RavenIcon().back, onPressed: () => Navigator.pop(context));

ElevatedButton receiveButton(context) => ElevatedButton.icon(
    icon: Icon(Icons.south_east),
    label: Text('Receive'),
    onPressed: () => Navigator.push(
        context, MaterialPageRoute(builder: (context) => Receive())),
    style: RavenButtonStyle().leftSideCurved);

ElevatedButton sendButton(context, {String asset = 'RVN'}) =>
    ElevatedButton.icon(
        icon: Icon(Icons.north_east),
        label: Text('Send'),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => Send(/* chosen asset*/))),
        style: RavenButtonStyle().rightSideCurved);

class RavenButton {
  RavenButton();

  IconButton back(context) => backIconButton(context);
  GestureDetector settings(context) => settingsButton(context);
  BottomAppBar bottomNav(context) => walletTradingButtons(context);
  ElevatedButton receive(context) => receiveButton(context);
  ElevatedButton send(context, {String asset = 'RVN'}) =>
      sendButton(context, asset: asset);
}
