import 'package:flutter/material.dart';

BottomAppBar walletTradingButtons() {
  return BottomAppBar(
      color: Colors.grey[300],
      child: ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
                onPressed: () {/*to wallet*/},
                icon: Icon(Icons.account_balance_wallet_rounded)),
            IconButton(
                onPressed: () {/*to trading*/}, icon: Icon(Icons.swap_horiz))
          ]));
}

Row sendReceiveButtons() {
  return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    ElevatedButton.icon(
        icon: Icon(Icons.south_east),
        label: Text('Receive'),
        onPressed: () {},
        style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0)))))),
    ElevatedButton.icon(
        icon: Icon(Icons.north_east),
        label: Text('Send'),
        onPressed: () {},
        style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))))))
  ]);
}
