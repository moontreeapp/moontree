import 'package:flutter/material.dart';
import 'package:raven_mobile/pages/receive.dart';
import 'package:raven_mobile/pages/send.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/styles.dart';

PreferredSize balanceHeader(context, data) {
  return PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          backgroundColor: RavenColor().appBar,
          automaticallyImplyLeading: true,
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: RavenButton().settings(context))
          ],
          elevation: 2,
          centerTitle: false,
          title: Text(
              (data['accounts'][data['account']] ?? 'Unknown') + ' Wallet',
              style: RavenTextStyle().h2),
          flexibleSpace: Container(
              color: RavenColor().appBar,
              alignment: Alignment.center,
              child: Text('\n\$ 0', style: RavenTextStyle().h1)),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: TabBar(
                  labelColor: Colors.grey[200],
                  indicatorColor: Colors.grey[400],
                  tabs: [Tab(text: 'Holdings'), Tab(text: 'Transactions')]))));
}

/// returns a list of holdings and transactions or empty messages
TabBarView holdingsTransactionsView(data) {
  var holdings;
  var transactions;
  if (data['holdings'][data['account']].isEmpty) {
    holdings = Container(
        color: Colors.grey,
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.savings, size: 50.0, color: Colors.grey[100]),
          Text('\nYour holdings will appear here.\n',
              style: RavenTextStyle().h2),
          ElevatedButton(
              onPressed: () {},
              child: Text('get RVN', style: RavenTextStyle().h2))
        ]));
  } else {
    holdings = ListView(children: <Widget>[
      for (var holding in data['holdings'][data['account']])
        ListTile(
            onTap: () {},
            title:
                Text(holding['asset'] + ' -- ' + holding['amount'].toString()),
            leading: CircleAvatar(
                backgroundImage: AssetImage('assets/ravenhead.png')))
    ]);
  }
  if (data['transactions'][data['account']].isEmpty) {
    transactions = Container(
        color: Colors.grey,
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.public, size: 50.0, color: Colors.grey[100]),
          Text('\nYour transactions will appear here.\n',
              style: RavenTextStyle().h2),
          ElevatedButton(
              onPressed: () {},
              child: Text('get RVN', style: RavenTextStyle().h2))
        ]));
  } else {
    transactions = ListView(children: <Widget>[
      for (var transaction in data['transactions'][data['account']])
        ListTile(
            onTap: () {},
            title: Text(transaction['asset'] +
                ' -- ' +
                transaction['direction'] +
                ' -- ' +
                transaction['amount'].toString()),
            leading: CircleAvatar(
                backgroundImage: AssetImage('assets/ravenhead.png')))
    ]);
  }
  // if empty return empty message:
  return TabBarView(children: [holdings, transactions]);
}

Drawer accountsView(context, data) {
  return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: <Widget>[
    DrawerHeader(
        decoration: BoxDecoration(color: RavenColor().appBar),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Wallets',
                  style: RavenTextStyle().getH2(color: Colors.grey[200])),
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                      onTap: () {},
                      child:
                          Icon(Icons.add, size: 26.0, color: Colors.grey[200])))
            ])),
    Column(children: <Widget>[
      for (var keyName in data['accounts'].entries) ...[
        ListTile(
            onTap: () {
              data['account'] = keyName.key;
              Navigator.pop(context);
            },
            title: Text(keyName.value),
            leading: CircleAvatar(
                backgroundImage: AssetImage('assets/ravenhead.png'))),
        Divider(
            height: 20,
            thickness: 2,
            indent: 5,
            endIndent: 5,
            color: Colors.grey[300])
      ]
    ])
  ]));
}

Row sendReceiveButtons(context) {
  return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    ElevatedButton.icon(
        icon: Icon(Icons.south_east),
        label: Text('Receive'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Receive()),
          );
        },
        style: RavenButtonStyle().leftSideCurved),
    ElevatedButton.icon(
        icon: Icon(Icons.north_east),
        label: Text('Send'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Send()),
          );
        },
        style: RavenButtonStyle().rightSideCurved)
  ]);
}
