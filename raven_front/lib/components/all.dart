import 'package:flutter/material.dart';
import 'package:raven_mobile/pages/settings/settings.dart';

BottomAppBar walletTradingButtons() {
  return BottomAppBar(
      color: Colors.grey[300],
      child: ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
                onPressed: () {/*to wallet*/},
                icon: Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.blue[900])),
            IconButton(
                onPressed: () {/*to trading*/}, icon: Icon(Icons.swap_horiz))
          ]));
}

GestureDetector settingsButton(context) {
  return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Settings()),
        );
      },
      child: Icon(Icons.more_horiz));
}
