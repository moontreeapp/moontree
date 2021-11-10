import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final accountName = TextEditingController();
  bool isFabVisible = true;

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
      if (changes.isNotEmpty) setState(() {});
    }));
    listeners.add(settings.batchedChanges.listen((batchedChanges) {
      // todo: set the current account on the widget
      var changes = batchedChanges
          .where((change) => change.data.name == SettingName.Account_Current);
      if (changes.isNotEmpty)
        setState(() {
          currentAccountId = changes.first.data.value;
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
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: balanceHeader(),
          drawer: accounts.data.length > 1 ? accountsView() : null,
          body: TabBarView(children: <Widget>[
            NotificationListener<UserScrollNotification>(
              onNotification: visibilityOfSendReceive,
              child: HoldingList(),
            ),
            NotificationListener<UserScrollNotification>(
              onNotification: visibilityOfSendReceive,
              child: TransactionList(),
            ),
          ]),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: isFabVisible ? sendReceiveButtons() : null,
          //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
        ));
  }

  bool visibilityOfSendReceive(notification) {
    if (notification.direction == ScrollDirection.forward) {
      if (!isFabVisible) setState(() => isFabVisible = true);
    } else if (notification.direction == ScrollDirection.reverse) {
      if (isFabVisible) setState(() => isFabVisible = false);
    }
    return true;
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
          title: SizedBox(
            height: 32,
            //child: Image.asset('assets/logo/moontree_logo.png'),
            //child: Image.asset('assets/logo/moontree_eclipse_dark_transparent.png'),
            child: accounts.data.length > 1
                ? Row(children: [
                    Text(Current.account.name),
                    Image.asset('assets/rvn256.png')
                  ])
                : Image.asset('assets/rvn256.png'),
            //child: Image.asset('assets/rvnonly.png'),
          ),
          ////Text(accounts.data.length > 1 ? Current.account.name : 'Wallet'),
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
              child: TabBar(tabs: [
                Tab(text: 'Holdings'),
                Tab(text: 'All Transactions')
              ]))));

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
                        hintText: 'Hodl')),
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
