import 'package:flutter/material.dart';

import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/extensions.dart';
import 'package:raven_mobile/theme.dart';

import 'package:flutter/cupertino.dart';
import 'package:raven_mobile/pages/asset.dart';
import 'package:raven_mobile/pages/raven.dart';
import 'package:raven_mobile/pages/transaction.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: balanceHeader(),
            drawer: accountsView(),
            body: holdingsTransactionsView(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: sendReceiveButtons(),
            bottomNavigationBar: RavenButton().bottomNav(context)));
  }

  PreferredSize balanceHeader() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          automaticallyImplyLeading: true,
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: RavenButton().settings(context))
          ],
          elevation: 2,
          centerTitle: false,
          title: Text(
              (data['accounts'][data['account']] ?? 'Unknown') + ' Wallet'),
          flexibleSpace: Container(
            alignment: Alignment.center,
            child: Text('\n\$ 0', style: Theme.of(context).textTheme.headline3),
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: TabBar(
                  tabs: [Tab(text: 'Holdings'), Tab(text: 'Transactions')]))));

  ListView _holdingsView() {
    var rvnHolding = <Widget>[];
    var assetHoldings = <Widget>[];
    if (data['holdings'][data['account']].isNotEmpty) {
      for (MapEntry holding in data['holdings'][data['account']].entries) {
        var thisHolding = ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => holding.key == 'RVN'
                          ? RavenTransactions()
                          : Asset()));
            },
            onLongPress: () {/* convert all values to USD and back */},
            title: Text(holding.key,
                style: holding.key == 'RVN'
                    ? Theme.of(context).textTheme.bodyText1
                    : Theme.of(context).textTheme.bodyText2),
            trailing: Text(holding.value.toString(),
                style: TextStyle(color: Theme.of(context).good)),
            leading: RavenIcon(asset: holding.key).assetAvatar);
        if (holding.key == 'RVN') {
          rvnHolding.add(thisHolding);
          if (holding.value < 600) {
            rvnHolding.add(ListTile(
                onTap: () {},
                title: Text('+ Create Asset (not enough RVN)',
                    style: TextStyle(color: Theme.of(context).disabledColor))));
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
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => RavenTransactions()));
          },
          onLongPress: () {/* convert all values to USD and back */},
          title: Text('RVN', style: Theme.of(context).textTheme.bodyText1),
          trailing: Text('0', style: TextStyle(color: Theme.of(context).fine)),
          leading: RavenIcon(asset: 'RVN').assetAvatar));
      rvnHolding.add(ListTile(
          onTap: () {},
          title: Text('+ Create Asset (not enough RVN)',
              style: TextStyle(color: Theme.of(context).disabledColor))));
    }

    return ListView(children: <Widget>[...rvnHolding, ...assetHoldings]);
  }

  ListView _transactionsView() => ListView(children: <Widget>[
        for (var transaction in data['transactions'][data['account']])
          ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Transaction()));
              },
              onLongPress: () {/* convert all values to USD and back */},
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(transaction['asset'],
                        style: Theme.of(context).textTheme.bodyText2),
                    (transaction['direction'] == 'in'
                        ? RavenIcon(context: context).income
                        : RavenIcon(context: context).out),
                  ]),
              trailing: (transaction['direction'] == 'in'
                  ? Text(transaction['amount'].toString(),
                      style: TextStyle(color: Theme.of(context).good))
                  : Text(transaction['amount'].toString(),
                      style: TextStyle(color: Theme.of(context).bad))),
              leading: RavenIcon(asset: transaction['asset']).assetAvatar)
      ]);

  Container _emptyMessage({IconData? icon, String? name}) => Container(
      color: Colors.grey,
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon ?? Icons.savings, size: 50.0, color: Colors.grey[100]),
        Text('\nYour $name will appear here.\n',
            style: Theme.of(context).textTheme.headline5),
        RavenButton().getRVN(context),
      ]));

  /// returns a list of holdings and transactions or empty messages
  TabBarView holdingsTransactionsView() => TabBarView(children: [
        data['holdings'][data['account']].isEmpty
            ? _emptyMessage(icon: Icons.savings, name: 'holdings')
            : _holdingsView(),
        data['transactions'][data['account']].isEmpty
            ? _emptyMessage(icon: Icons.public, name: 'transactions')
            : _transactionsView(),
      ]);

  Drawer accountsView() => Drawer(
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
        DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Wallets', style: Theme.of(context).textTheme.headline5),
                  Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                          onTap: () {},
                          child: Icon(Icons.add,
                              size: 26.0, color: Colors.grey.shade200)))
                ])),
        Column(children: <Widget>[
          for (var keyName in data['accounts'].entries) ...[
            ListTile(
                onTap: () {
                  data['account'] = keyName.key;
                  Navigator.pop(context);
                },
                title: Text(keyName.value,
                    style: Theme.of(context).textTheme.bodyText1),
                leading: RavenIcon(asset: 'RVN').assetAvatar),
            Divider(height: 20, thickness: 2, indent: 5, endIndent: 5)
          ]
        ])
      ]));

  Row sendReceiveButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        RavenButton().receive(context),
        RavenButton().send(context, asset: 'RVN'),
      ]);
}
