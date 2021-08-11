import 'package:flutter/material.dart';

PreferredSize balanceHeader(context, data) {
  return PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          backgroundColor: Colors.blue[900],
          automaticallyImplyLeading: true,
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                    onTap: () {}, child: Icon(Icons.more_horiz)))
          ],
          elevation: 2,
          centerTitle: false,
          title: Text(
              (data['accounts'][data['account']] ?? 'Unknown') + ' Wallet',
              style: TextStyle(fontSize: 18.0, letterSpacing: 2.0)),
          flexibleSpace: Container(
              color: Colors.blue[900],
              alignment: Alignment.center,
              child: Text('\n\$ 0',
                  style: TextStyle(
                      fontSize: 24.0,
                      letterSpacing: 2.0,
                      color: Colors.white))),
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
          Text('\nYour holdings will appear here.',
              style: TextStyle(
                  fontSize: 18.0, letterSpacing: 2.0, color: Colors.white))
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
          Text('\nYour transactions will appear here.',
              style: TextStyle(
                  fontSize: 18.0, letterSpacing: 2.0, color: Colors.white))
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

Drawer accountsView(data) {
  return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: <Widget>[
    DrawerHeader(
        decoration: BoxDecoration(color: Colors.blue[900]),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Wallets',
                  style: TextStyle(
                      fontSize: 18.0,
                      letterSpacing: 2.0,
                      color: Colors.grey[200])),
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
            onTap: () => data['account'] = keyName.key,
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
