import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven/services/transaction.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/indicators/indicators.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/utils/utils.dart';

class RavenTransactions extends StatefulWidget {
  @override
  _RavenTransactionsState createState() => _RavenTransactionsState();
}

class _RavenTransactionsState extends State<RavenTransactions> {
  Map<String, dynamic> data = {};
  bool showUSD = false;
  late List<TransactionRecord> currentTxs;
  late List<Balance> currentHolds;
  late Balance currentBalRVN;

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
    data = populateData(context, data);
    if (data.containsKey('walletId') && data['walletId'] != null) {
      currentTxs = Current.walletCompiledTransactions(data['walletId']);
      currentHolds = Current.walletHoldings(data['walletId']);
      currentBalRVN = Current.walletBalanceRVN(data['walletId']);
    } else {
      currentTxs = Current.compiledTransactions;
      currentHolds = Current.holdings;
      currentBalRVN = Current.balanceRVN;
    }
    return Scaffold(
      appBar: header(),
      body: components.lists.transactionsView(
        context,
        showUSD: showUSD,
        transactions: currentTxs.where((tx) => tx.security == securities.RVN),
        onLongPress: _toggleUSD,
        refresh: setState,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: sendReceiveButtons(),
      //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
    );
  }

  PreferredSize header() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          elevation: 2,
          centerTitle: false,
          leading: components.buttons.back(context),
          actions: <Widget>[
            components.status,
            indicators.process,
            indicators.client,
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: components.buttons.settings(context))
          ],
          title: Text('RVN'),
          flexibleSpace: Container(
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 45.0),
                    Container(
                        height: 90,
                        width: 90,
                        child: components.icons.assetAvatar('RVN')),
                    SizedBox(height: 5.0),
                    Text(
                        components.text.securityAsReadable(currentBalRVN.value,
                            symbol: 'RVN'),
                        style: Theme.of(context).textTheme.headline3),
                    SizedBox(height: 10.0),
                    Text(components.text.rvnUSD(currentBalRVN.rvn),
                        style: Theme.of(context).textTheme.headline5),
                  ]))));

  Row sendReceiveButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        components.buttons.receive(context),
        currentHolds.length > 0
            ? components.buttons.send(context, symbol: 'RVN')
            : components.buttons.send(context, symbol: 'RVN', disabled: true),
      ]);
}
