import 'package:flutter/material.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/styles/buttons.dart';
import 'package:raven_mobile/theme/extensions.dart';

BottomAppBar walletTradingButtons(context) => BottomAppBar(
        child: ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
          IconButton(
              onPressed: () {/*to wallet*/},
              icon: Icon(Icons.account_balance_wallet_rounded,
                  color: Theme.of(context).primaryColor)),
          IconButton(
              onPressed: () {/*to trading*/}, icon: Icon(Icons.swap_horiz))
        ]));

GestureDetector settingsButton(context) => GestureDetector(
    onTap: () => Navigator.pushNamed(context, '/settings'),
    child: Icon(Icons.more_horiz));

IconButton backIconButton(context) =>
    IconButton(icon: RavenIcon.back, onPressed: () => Navigator.pop(context));

ElevatedButton receiveButton(context) => ElevatedButton.icon(
    icon: Icon(Icons.south_east),
    label: Text('Receive'),
    onPressed: () => Navigator.pushNamed(context, '/receive'),
    style: RavenButtonStyle.leftSideCurved);

ElevatedButton sendButton(context, {String symbol = 'RVN'}) =>
    ElevatedButton.icon(
        icon: Icon(Icons.north_east),
        label: Text('Send'),
        onPressed: () => Navigator.pushNamed(context, '/send',
            arguments: {'symbol': symbol}),
        style: RavenButtonStyle.rightSideCurved);

ElevatedButton getRVNButton(context) => ElevatedButton(
      onPressed: () {/* link to coinbase */},
      child: Text('get RVN', style: Theme.of(context).textTheme.headline2),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Theme.of(context).good)),
    );

class RavenButton {
  RavenButton();

  static IconButton back(context) => backIconButton(context);
  static GestureDetector settings(context) => settingsButton(context);
  static BottomAppBar bottomNav(context) => walletTradingButtons(context);
  static ElevatedButton receive(context) => receiveButton(context);
  static ElevatedButton send(context, {String symbol = 'RVN'}) =>
      sendButton(context, symbol: symbol);
  static ElevatedButton getRVN(context) => getRVNButton(context);
}
