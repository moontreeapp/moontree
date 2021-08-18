import 'package:flutter/material.dart';
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

class RavenButton {
  RavenButton();

  IconButton back(context) => backIconButton(context);
  GestureDetector settings(context) => settingsButton(context);
  BottomAppBar bottomNav(context) => walletTradingButtons(context);
}
