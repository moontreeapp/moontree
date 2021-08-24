import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:raven/records/setting_name.dart';

import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/text.dart';
import 'package:raven_mobile/theme/extensions.dart';
import 'package:raven_mobile/theme/theme.dart';

import 'package:raven/init/reservoirs.dart' as res;
import 'package:raven/init/services.dart' as services;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  dynamic data = {};
  int balance = 0;
  bool showUSD = false;

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
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    //balance = services.ratesService.accountBalanceUSD('0').value;
    balance = data['holdings'][data['account']]['RVN'] ?? 0;
    print(res.accounts.get('0'));
    var titleId = res.settings.get(SettingName.Current_Account)?.value ?? '0';
    print(titleId);
    var title = res.accounts.get(titleId)?.name ?? 'asdf';
    print(title);
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: balanceHeader(title),
            drawer: accountsView(),
            body: holdingsTransactionsView(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: sendReceiveButtons(),
            bottomNavigationBar: RavenButton.bottomNav(context)));
  }

  PreferredSize balanceHeader(title) => PreferredSize(
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
          title: Text(title),
          flexibleSpace: Container(
            alignment: Alignment.center,
            child: Text('\n\$ ${RavenText.rvnUSD(balance)}',
                style: Theme.of(context).textTheme.headline3),
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
            onTap: () => Navigator.pushNamed(
                context, holding.key == 'RVN' ? '/transactions' : '/asset'),
            onLongPress: () => _toggleUSD(),
            title: Text(holding.key,
                style: holding.key == 'RVN'
                    ? Theme.of(context).textTheme.bodyText1
                    : Theme.of(context).textTheme.bodyText2),
            trailing: (Text(
                showUSD
                    ? (holding.key == 'RVN'
                        ? '\$' + RavenText.rvnUSD(holding.value)
                        : holding.value
                            .toString()) //'\$' + RavenText.rvnUSD(RavenText.assetRVN(transaction['amount']))
                    : holding.value.toString(),
                style: TextStyle(color: Theme.of(context).good))),
            leading: RavenIcon.assetAvatar(holding.key));
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
        for (var transaction in data['transactions'][data['account']])
          ListTile(
              onTap: () => Navigator.pushNamed(context, '/transactions'),
              onLongPress: () => _toggleUSD(),
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(transaction['asset'],
                        style: Theme.of(context).textTheme.bodyText2),
                    (transaction['direction'] == 'in'
                        ? RavenIcon.income(context)
                        : RavenIcon.out(context)),
                  ]),
              trailing: (transaction['direction'] == 'in'
                  ? Text(
                      showUSD
                          ? (transaction['asset'] == 'RVN'
                              ? '\$' + RavenText.rvnUSD(transaction['amount'])
                              : transaction['amount'].toString())
                          : transaction['amount'].toString(),
                      style: TextStyle(color: Theme.of(context).good))
                  : Text(
                      showUSD
                          ? (transaction['asset'] == 'RVN'
                              ? '\$' + RavenText.rvnUSD(transaction['amount'])
                              : transaction['amount'].toString())
                          : transaction['amount'].toString(),
                      style: TextStyle(color: Theme.of(context).bad))),
              leading: RavenIcon.assetAvatar(transaction['asset']))
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
                  Text('Accounts',
                      style: Theme.of(context).textTheme.headline5),
                  Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                          onTap: () {},
                          child: Icon(Icons.add,
                              size: 26.0, color: Colors.grey.shade200)))
                ])),
        Column(children: <Widget>[
          for (var account in res.accounts.data) ...[
            ListTile(
                onTap: () {
                  /// the reason it can't be contained to this page is that the
                  /// current account is not contained to this page.
                  //data['account'] = keyName.key;
                  services.settingsService
                      .saveSetting(SettingName.Current_Account, account.id);
                  Navigator.pop(context);
                },
                title: Text(account.id + ' ' + account.name,
                    style: Theme.of(context).textTheme.bodyText1),
                leading: RavenIcon.assetAvatar('RVN')),
            Divider(height: 20, thickness: 2, indent: 5, endIndent: 5)
          ]
        ])
      ]));

  Row sendReceiveButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        RavenButton.receive(context),
        RavenButton.send(context, asset: 'RVN'),
      ]);
}
