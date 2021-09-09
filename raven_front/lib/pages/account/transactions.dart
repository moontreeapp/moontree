import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/text.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/theme/extensions.dart';

class RavenTransactions extends StatefulWidget {
  @override
  _RavenTransactionsState createState() => _RavenTransactionsState();
}

class _RavenTransactionsState extends State<RavenTransactions> {
  bool showUSD = false;

  void _toggleUSD() {
    setState(() {
      showUSD = !showUSD;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                child: RavenButton.settings(context, () {
                  setState(() {});
                }))
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
                    Text(
                        RavenText.securityAsReadable(Current.balanceRVN.value,
                            symbol: 'RVN'),
                        style: Theme.of(context).textTheme.headline3),
                    SizedBox(height: 15.0),
                    Text(RavenText.rvnUSD(Current.balanceRVN.rvn),
                        style: Theme.of(context).textTheme.headline5),
                  ]))));

  Container _transactionsView() => Container(
      alignment: Alignment.center,
      child: ListView(children: <Widget>[
        for (var transaction in Current.transactions) ...[
          if (transaction.security.symbol == 'RVN')
            ListTile(
                onTap: () => Navigator.pushNamed(context, '/transaction',
                    arguments: {'transaction': transaction}),
                onLongPress: () => _toggleUSD(),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(transaction.security.symbol,
                          style: Theme.of(context).textTheme.bodyText2),
                      (transaction.value > 0 // == 'in'
                          ? RavenIcon.income(context)
                          : RavenIcon.out(context)),
                    ]),
                trailing: (transaction.value > 0 // == 'in'
                    ? Text(
                        RavenText.securityAsReadable(transaction.value,
                            symbol: 'RVN', asUSD: showUSD),
                        style: TextStyle(color: Theme.of(context).good))
                    : Text(
                        RavenText.securityAsReadable(transaction.value,
                            symbol: 'RVN', asUSD: showUSD),
                        style: TextStyle(color: Theme.of(context).bad))),
                leading: RavenIcon.assetAvatar(transaction.security.symbol))
        ]
      ]));

  Container _emptyMessage({IconData? icon, String? name}) => Container(
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon ?? Icons.description,
            size: 50.0, color: Theme.of(context).secondaryHeaderColor),
        Text('\nMagic Musk $name empty.\n',
            style: Theme.of(context).textTheme.headline3),
      ]));

  /// returns a list of holdings and transactions or empty messages
  Container transactionsView() => Current.transactions.isEmpty
      ? _emptyMessage(icon: Icons.public, name: 'transactions')
      : _transactionsView();

  Row sendReceiveButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        RavenButton.receive(context),
        Current.holdings.length > 0
            ? RavenButton.send(context, symbol: 'RVN')
            : RavenButton.send(context, symbol: 'RVN', disabled: true),
      ]);
}
