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
          title: Text((data['account'] ?? 'Unknown') + ' Wallet',
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

TabBarView holdingsTransactionsView() {
  // if full return list of holdings and transactions with RVN being special...
  // if empty return empty message:
  return TabBarView(children: [
    Container(
        color: Colors.grey,
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.savings, size: 50.0, color: Colors.grey[100]),
          Text('\nYour holdings will appear here.',
              style: TextStyle(
                  fontSize: 18.0, letterSpacing: 2.0, color: Colors.white))
        ])),
    Container(
        color: Colors.grey,
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.public, size: 50.0, color: Colors.grey[100]),
          Text('\nYour transactions will appear here.',
              style: TextStyle(
                  fontSize: 18.0, letterSpacing: 2.0, color: Colors.white))
        ]))
  ]);
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
      for (var name in data['accounts'].values) ...[
        ListTile(
            onTap: () {},
            title: Text(name),
            leading: CircleAvatar(
                backgroundImage: AssetImage('assets/ravenhead.png'))),
        Divider(
            height: 20,
            thickness: 2,
            indent: 4,
            endIndent: 4,
            color: Colors.grey[300])
      ]
    ])
  ]));
}
