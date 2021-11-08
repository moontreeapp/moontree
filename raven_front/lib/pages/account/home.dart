import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/widgets/widgets.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/indicators/indicators.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/theme/theme.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<StreamSubscription> listeners =
      []; // most of these can move to header and body elements
  late String currentAccountId = '0'; // should be moved to body?
  late Account currentAccount; // should be moved to body?
  Rate? rateUSD; // to header and body
  Balance? accountBalance; // to header
  bool showUSD = false; // list in body
  final accountName = TextEditingController();

  @override
  void initState() {
    super.initState();
    // gets cleaned up?
    currentTheme.addListener(() {
      // if user changes OS dark/light mode setting, refresh
      setState(() {});
    });
    listeners.add(balances.batchedChanges.listen((batchedChanges) {
      // if we update balance for the account we're looking at:
      var changes = batchedChanges.where((change) =>
          change.data.account?.accountId == Current.account.accountId);
      if (changes.isNotEmpty)
        setState(() {
          accountBalance = changes.first.data;
        });
    }));

    /// this shouldn't be necessary if balances have updated.
    //listeners
    //    .add(vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
    //  // if vouts in our account has changed...
    //  if (batchedChanges
    //      .where((change) =>
    //          change.data.address?.wallet?.accountId ==
    //          Current.account.accountId)
    //      .isNotEmpty) {
    //    setState(() {});
    //  }
    //}));
    // we can move a wallet from one account to another
    //listeners.add(wallets.batchedChanges.listen((batchedChanges) {
    //  setState(() {});
    //}));
    listeners.add(rates.batchedChanges.listen((batchedChanges) {
      // TODO: should probably include any assets that are in the holding of the main account too...
      var changes = batchedChanges.where((change) =>
          change.data.base == securities.RVN &&
          change.data.quote == securities.USD);
      if (changes.isNotEmpty)
        setState(() {
          rateUSD = changes.first.data;
        });
    }));
    listeners.add(settings.batchedChanges.listen((batchedChanges) {
      // todo: set the current account on the widget
      var changes = batchedChanges
          .where((change) => change.data.name == SettingName.Account_Current);
      if (changes.isNotEmpty)
        setState(() {
          currentAccountId = changes.first.data.value;
          currentAccount = accounts.primaryIndex.getOne(currentAccountId)!;
        });
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
    services.rate.saveRate();
    services.balance.recalculateAllBalances();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    currentAccount = accounts.primaryIndex.getOne(currentAccountId)!;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: balanceHeader(),
          drawer: accounts.data.length > 1 ? accountsView() : null,
          body: TabBarView(children: <Widget>[
            HoldingList(currentAccountId: currentAccountId),
            TransactionList(currentAccountId: currentAccountId)
          ]),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: sendReceiveButtons(),
          //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
        ));
  }

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
                child: components.buttons.settings(context))
          ],
          elevation: 2,
          centerTitle: false,
          title:
              Text(accounts.data.length > 1 ? currentAccount.name : 'Wallet'),
          flexibleSpace: Container(
            alignment: Alignment.center,
            // balance view should listen for valid usd
            // show spinnter until valid usd rate appears, then rvnUSD
            child: Text(
                // this kinda thing should be abstracted:
                '\n${Current.balanceUSD != null ? '\$' : 'RVN'} ${Current.balanceUSD?.valueUSD ?? Current.balanceRVN.rvn}',
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
