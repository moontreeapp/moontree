import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/indicators/indicators.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/theme/theme.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<StreamSubscription> listeners = [];
  bool showUSD = false;
  final accountName = TextEditingController();

  void _toggleUSD() {
    setState(() {
      if (rates.primaryIndex.getOne(securities.RVN, securities.USD) == null) {
        showUSD = false;
      } else {
        showUSD = !showUSD;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // gets cleaned up?
    currentTheme.addListener(() {
      setState(() {});
    });
    listeners.add(balances.batchedChanges.listen((batchedChanges) {
      setState(() {});
    }));
    listeners
        .add(vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
      if ([
        for (var change in batchedChanges)
          if ((change.data).address?.wallet?.accountId ==
              Current.account.accountId)
            1
      ].contains(1)) setState(() {});
    }));
    // we can move a wallet from one account to another
    listeners.add(wallets.batchedChanges.listen((batchedChanges) {
      setState(() {});
    }));
    listeners.add(settings.batchedChanges.listen((batchedChanges) {
      setState(() {});
    }));
  }

  @override
  void dispose() {
    //This method must not be called after dispose has been called. ??
    //currentTheme.removeListener(() {});
    for (var listener in listeners) {
      listener.cancel();
    }
    accountName.dispose();
    super.dispose();
  }

  void refresh([Function? f]) {
    services.balance.recalculateAllBalances();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: balanceHeader(),
        drawer: accounts.data.length > 1 ? accountsView() : null,
        body: TabBarView(children: [
          components.lists.holdingsView(context,
              showUSD: showUSD,
              holdings: Current.holdings,
              onLongPress: _toggleUSD,
              refresh: refresh),
          components.lists.transactionsView(context,
              showUSD: showUSD,
              transactions: Current.compiledTransactions,
              onLongPress: _toggleUSD,
              refresh: refresh)
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: sendReceiveButtons(),
        //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
      ));

  PreferredSize balanceHeader() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          automaticallyImplyLeading: true,
          actions: <Widget>[
            components.status,
            indicators.process,
            indicators.client,
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: components.buttons.settings(context, () {
                  setState(() {});
                }))
          ],
          elevation: 2,
          centerTitle: false,
          title:
              Text(accounts.data.length > 1 ? Current.account.name : 'Wallet'),
          flexibleSpace: Container(
            alignment: Alignment.center,
            // balance view should listen for valid usd
            // show spinnter until valid usd rate appears, then rvnUSD
            child: Text(
                '\n\$ ${Current.balanceUSD?.valueUSD ?? Current.balanceRVN.value}',
                style: Theme.of(context).textTheme.headline3),
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: TabBar(
                  tabs: [Tab(text: 'Holdings'), Tab(text: 'Transactions')]))));

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
                          onTap: () => Navigator.pushNamed(
                              context, '/settings/technical'),
                          child: Icon(Icons.more_vert,
                              size: 26.0, color: Colors.grey.shade200)))
                ])),
        Column(children: <Widget>[
          for (var account in accounts.data) ...[
            ListTile(
                onTap: () async {
                  await settings.setCurrentAccountId(account.accountId);
                  accountName.text = '';
                  Navigator.pop(context);
                  setState(() {});
                },
                title: Text(account.accountId + ' ' + account.name,
                    style: Theme.of(context).textTheme.bodyText1),
                leading: components.icons.assetAvatar('RVN')),
            Divider(height: 20, thickness: 2, indent: 5, endIndent: 5)
          ],
          ...[
            ListTile(
                onTap: () async {
                  var account =
                      await services.account.createSave(accountName.text);
                  await settings.save(Setting(
                      name: SettingName.Account_Current,
                      value: account.accountId));
                  Navigator.pop(context);
                },
                title: TextField(
                    readOnly: false,
                    controller: accountName,
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Create Account',
                        hintText: 'Billz')),
                trailing:
                    Icon(Icons.add, size: 26.0, color: Colors.grey.shade800)),
            Divider(height: 20, thickness: 2, indent: 5, endIndent: 5)
          ],
        ])
      ]));

  Row sendReceiveButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        components.buttons.receive(context),
        Current.holdings.length > 0
            ? components.buttons.send(context, symbol: 'RVN')
            : components.buttons.send(context, symbol: 'RVN', disabled: true),
      ]);
}
