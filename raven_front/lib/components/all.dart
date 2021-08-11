import 'package:flutter/material.dart';

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
