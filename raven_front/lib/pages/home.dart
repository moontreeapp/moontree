import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:raven/raven.dart';

import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/text.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/theme/extensions.dart';
import 'package:raven_mobile/theme/theme.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool showUSD = false;
  final accountName = TextEditingController();

  void _toggleUSD() {
    setState(() {
      showUSD = !showUSD;
    });
  }

  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      setState(() {});
    });
    balances.changes.listen((changes) {
      setState(() {});
    });
    settings.changes.listen((changes) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    accountName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: balanceHeader(),
            drawer: accountsView(),
            body: holdingsTransactionsView(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: sendReceiveButtons(),
            bottomNavigationBar: RavenButton.bottomNav(context)));
  }

  PreferredSize balanceHeader() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          automaticallyImplyLeading: true,
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: RavenButton.settings(context))
          ],
          elevation: 2,
          centerTitle: false,
          title: Text(Current.account.name),
          flexibleSpace: Container(
            alignment: Alignment.center,
            // balance view should listen for valid usd
            // show spinnter until valid usd rate appears, then rvnUSD
            child: Text('\n\$ ${Current.balanceUSD.valueUSD}',
                style: Theme.of(context).textTheme.headline3),
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: TabBar(
                  tabs: [Tab(text: 'Holdings'), Tab(text: 'Transactions')]))));

  ListView _holdingsView() {
    var rvnHolding = <Widget>[];
    var assetHoldings = <Widget>[];
    for (var holding in Current.holdings) {
      var thisHolding = ListTile(
          onTap: () => Navigator.pushNamed(context,
              holding.security.symbol == 'RVN' ? '/transactions' : '/asset',
              arguments: {'holding': holding}),
          onLongPress: () => _toggleUSD(),
          title: Text(holding.security.symbol,
              style: holding.security.symbol == 'RVN'
                  ? Theme.of(context).textTheme.bodyText1
                  : Theme.of(context).textTheme.bodyText2),
          trailing: (Text(
              showUSD
                  ? RavenText.securityInUSD(holding.value,
                      security: holding.security)
                  : holding.value.toString(),
              style: TextStyle(color: Theme.of(context).good))),
          leading: RavenIcon.assetAvatar(holding.security.symbol));
      if (holding.security.symbol == 'RVN') {
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
    if (rvnHolding.isEmpty) {
      rvnHolding.add(ListTile(
          onTap: () => Navigator.pushNamed(context, '/transactions'),
          onLongPress: () => _toggleUSD(),
          title: Text('RVN', style: Theme.of(context).textTheme.bodyText1),
          trailing: Text(showUSD ? '\$ 0' : '0',
              style: TextStyle(color: Theme.of(context).fine)),
          leading: RavenIcon.assetAvatar('RVN')));
      rvnHolding.add(ListTile(
          onTap: () {},
          title: Text('+ Create Asset (not enough RVN)',
              style: TextStyle(color: Theme.of(context).disabledColor))));
    }

    return ListView(children: <Widget>[...rvnHolding, ...assetHoldings]);
  }

  ListView _transactionsView() => ListView(children: <Widget>[
        for (var transaction in Current.transactions)
          ListTile(
              onTap: () => Navigator.pushNamed(context, '/transaction',
                  arguments: {'transaction': transaction}),
              onLongPress: () => _toggleUSD(),
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(transaction.security.symbol,
                        style: Theme.of(context).textTheme.bodyText2),
                    (transaction.value > 0 //  == 'in'
                        ? RavenIcon.income(context)
                        : RavenIcon.out(context)),
                  ]),
              trailing: (transaction.value > 0 // == 'in'
                  ? Text(
                      showUSD
                          ? RavenText.securityInUSD(transaction.value,
                              security: transaction.security)
                          : transaction.value.toString(),
                      style: TextStyle(color: Theme.of(context).good))
                  : Text(
                      showUSD
                          ? RavenText.securityInUSD(transaction.value,
                              security: transaction.security)
                          : transaction.value.toString(),
                      style: TextStyle(color: Theme.of(context).bad))),
              leading: RavenIcon.assetAvatar(transaction.security.symbol))
      ]);

  Container _emptyMessage({IconData? icon, String? name}) => Container(
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon ?? Icons.savings,
            size: 50.0, color: Theme.of(context).secondaryHeaderColor),
        Text('\nYour $name will appear here.\n',
            style: Theme.of(context).textTheme.bodyText1),
        RavenButton.getRVN(context),
      ]));

  /// returns a list of holdings and transactions or empty messages
  TabBarView holdingsTransactionsView() => TabBarView(children: [
        Current.holdings.isEmpty
            ? _emptyMessage(icon: Icons.savings, name: 'holdings')
            : _holdingsView(),
        Current.transactions.isEmpty
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
                  Text('Accounts',
                      style: Theme.of(context).textTheme.headline5),
                  Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                          onTap: () {/* to technical view */},
                          child: Icon(Icons.edit,
                              size: 26.0, color: Colors.grey.shade200)))
                ])),
        Column(children: <Widget>[
          for (var account in accounts.data) ...[
            ListTile(
                onTap: () async {
                  await settingsService.saveSetting(
                      SettingName.Current_Account, account.id);
                  Navigator.pop(context);
                },
                title: Text(account.id + ' ' + account.name,
                    style: Theme.of(context).textTheme.bodyText1),
                leading: RavenIcon.assetAvatar('RVN')),
            Divider(height: 20, thickness: 2, indent: 5, endIndent: 5)
          ],
          ...[
            ListTile(
                onTap: () async {
                  var account = await accountGenerationService
                      .makeAndAwaitSaveAccount(accountName.text);
                  await settingsService.saveSetting(
                      SettingName.Current_Account, account.id);
                  Navigator.pop(context);
                },
                title: TextField(
                  readOnly: false,
                  controller: accountName,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Create Account',
                      hintText: 'Bills'),
                ),
                trailing:
                    Icon(Icons.add, size: 26.0, color: Colors.grey.shade800)),
            Divider(height: 20, thickness: 2, indent: 5, endIndent: 5)
          ]
        ])
      ]));

  Row sendReceiveButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        RavenButton.receive(context),
        Current.holdings.length > 0
            ? RavenButton.send(context, symbol: 'RVN')
            : RavenButton.send(context, symbol: 'RVN', disabled: true),
      ]);
}
