import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/services/account_mock.dart' as mock;
import 'package:raven_mobile/theme/extensions.dart';
import 'package:raven_mobile/pages/transaction.dart';

class RavenTransactions extends StatefulWidget {
  @override
  _RavenTransactionsState createState() => _RavenTransactionsState();
}

class _RavenTransactionsState extends State<RavenTransactions> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //data = data.isNotEmpty ??
    //    data ??
    //    ModalRoute.of(context)!.settings.arguments ??
    data = {
      'account': 'accountId2',
      'accounts': mock.Accounts.instance.accounts,
      'transactions': mock.Accounts.instance.transactions,
      'holdings': mock.Accounts.instance.holdings,
    };
    return Scaffold(
        appBar: header(),
        body: transactionsView(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: sendReceiveButtons(),
        bottomNavigationBar: RavenButton.bottomNav(context));
  }

  PreferredSize header() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          elevation: 2,
          centerTitle: false,
          leading: RavenButton.back(context),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: RavenButton.settings(context))
          ],
          title: Text('RVN'),
          flexibleSpace: Container(
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 15.0),
                    RavenIcon.assetAvatar('RVN'),
                    SizedBox(height: 15.0),
                    Text('50', style: Theme.of(context).textTheme.headline3),
                    SizedBox(height: 15.0),
                    Text('\$654.02',
                        style: Theme.of(context).textTheme.headline5),
                  ]))));

  Container _transactionsView() {
    var txs = <Widget>[];
    for (var transaction in data['transactions'][data['account']]) {
      if (transaction['asset'] == 'RVN') {
        txs.add(ListTile(
            onTap: () => Navigator.pushNamed(context, '/transaction'),
            onLongPress: () {/* convert all values to USD and back */},
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
                ? Text(transaction['amount'].toString(),
                    style: TextStyle(color: Theme.of(context).good))
                : Text(transaction['amount'].toString(),
                    style: TextStyle(color: Theme.of(context).bad))),
            leading: RavenIcon.assetAvatar(transaction['asset'])));
      }
    }
    return Container(
        alignment: Alignment.center, child: ListView(children: txs));
  }

  Container _emptyMessage({IconData? icon, String? name}) => Container(
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon ?? Icons.description,
            size: 50.0, color: Theme.of(context).secondaryHeaderColor),
        Text('\nMagic Musk $name empty.\n',
            style: Theme.of(context).textTheme.headline4),
      ]));

  /// returns a list of holdings and transactions or empty messages
  Container transactionsView() => data['transactions'][data['account']].isEmpty
      ? _emptyMessage(icon: Icons.public, name: 'transactions')
      : _transactionsView();

  /// different from home.sendReceiveButtons because it prefills the chosen token
  /// receive works the same
  Row sendReceiveButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        RavenButton.receive(context),
        RavenButton.send(context, asset: 'RVN'),
      ]);
}
