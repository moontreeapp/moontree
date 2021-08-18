import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raven_mobile/pages/receive.dart';
import 'package:raven_mobile/pages/send.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/pages/transaction.dart';
import 'package:raven_mobile/styles.dart';

PreferredSize balanceHeader(context, data) => PreferredSize(
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
        title: RavenText(
                (data['accounts'][data['account']] ?? 'Unknown') + ' Wallet')
            .h2,
        flexibleSpace: Container(
            color: RavenColor().appBar,
            alignment: Alignment.center,
            child: RavenText('\n\$ 0').h1),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: TabBar(
                labelColor: RavenColor().offWhite,
                indicatorColor: Colors.grey[400],
                tabs: [Tab(text: 'Holdings'), Tab(text: 'Transactions')]))));

ListView _holdingsView(context, data) {
  var rvnHolding = <Widget>[];
  var assetHoldings = <Widget>[];
  if (data['holdings'][data['account']].isNotEmpty) {
    for (MapEntry holding in data['holdings'][data['account']].entries) {
      var thisHolding = ListTile(
          onTap: () {},
          onLongPress: () {/* convert all values to USD and back */},
          title: RavenText(holding.key).name,
          trailing: RavenText(holding.value.toString()).good,
          leading: RavenIcon().getAssetAvatar(holding.key));
      if (holding.key == 'rvn') {
        rvnHolding.add(thisHolding);
        if (holding.value < 600) {
          rvnHolding.add(ListTile(
              onTap: () {},
              title: RavenText('+ Create Asset (not enough RVN)').disabled));
        } else {
          rvnHolding.add(ListTile(
              onTap: () {},
              title: TextButton.icon(
                  onPressed: () {/* create asset screen */},
                  icon: Icon(Icons.add),
                  label: Text('Create Asset'))));
        }
      } else {
        assetHoldings.add(thisHolding);
      }
    }
  }
  if (rvnHolding.isEmpty) {
    rvnHolding.add(ListTile(
        onTap: () {},
        onLongPress: () {/* convert all values to USD and back */},
        title: RavenText('rvn').name,
        trailing: RavenText('0').fine,
        leading: RavenIcon().getAssetAvatar('rvn')));
    rvnHolding.add(ListTile(
        onTap: () {},
        title: RavenText('+ Create Asset (not enough RVN)').disabled));
  }

  return ListView(children: <Widget>[...rvnHolding, ...assetHoldings]);
}

ListView _transactionsView(context, data) => ListView(children: <Widget>[
      for (var transaction in data['transactions'][data['account']])
        ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Transaction()),
              );
            },
            onLongPress: () {/* convert all values to USD and back */},
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RavenText(transaction['asset']).name,
                  (transaction['direction'] == 'in'
                      ? RavenIcon().income
                      : RavenIcon().out),
                ]),
            trailing: (transaction['direction'] == 'in'
                ? RavenText(transaction['amount'].toString()).good
                : RavenText(transaction['amount'].toString()).bad),
            leading: RavenIcon().getAssetAvatar(transaction['asset']))
    ]);

Container _emptyMessage({IconData? icon, String? name}) => Container(
    color: Colors.grey,
    alignment: Alignment.center,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon ?? Icons.savings, size: 50.0, color: Colors.grey[100]),
      RavenText('\nYour $name will appear here.\n').h2,
      ElevatedButton(onPressed: () {}, child: RavenText('get RVN').h2)
    ]));

/// returns a list of holdings and transactions or empty messages
TabBarView holdingsTransactionsView(context, data) => TabBarView(children: [
      data['holdings'][data['account']].isEmpty
          ? _emptyMessage(icon: Icons.savings, name: 'holdings')
          : _holdingsView(context, data),
      data['transactions'][data['account']].isEmpty
          ? _emptyMessage(icon: Icons.public, name: 'transactions')
          : _transactionsView(context, data),
    ]);

Drawer accountsView(context, data) => Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      DrawerHeader(
          decoration: BoxDecoration(color: RavenColor().appBar),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RavenText('Wallets').getH2(color: RavenColor().offWhite),
                Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                        onTap: () {},
                        child: Icon(Icons.add,
                            size: 26.0, color: RavenColor().offWhite)))
              ])),
      Column(children: <Widget>[
        for (var keyName in data['accounts'].entries) ...[
          ListTile(
              onTap: () {
                data['account'] = keyName.key;
                Navigator.pop(context);
              },
              title: RavenText(keyName.value).name,
              leading: RavenIcon().getAssetAvatar('rvn')),
          Divider(
              height: 20,
              thickness: 2,
              indent: 5,
              endIndent: 5,
              color: RavenColor().offWhite)
        ]
      ])
    ]));

Row sendReceiveButtons(context) =>
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
