import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven/services/transaction.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/utils/utils.dart';
import 'package:raven_mobile/components/components.dart';

class Asset extends StatefulWidget {
  final dynamic data;
  const Asset({this.data}) : super();

  @override
  _AssetState createState() => _AssetState();
}

class _AssetState extends State<Asset> {
  Map<String, dynamic> data = {};
  late List<TransactionRecord> currentTxs;
  late List<Balance> currentHolds;
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
    data = populateData(context, data);
    currentTxs = data.containsKey('walletId') && data['walletId'] != null
        ? Current.walletCompiledTransactions(data['walletId'])
        : Current.compiledTransactions;
    currentHolds = data.containsKey('walletId') && data['walletId'] != null
        ? Current.walletHoldings(data['walletId'])
        : Current.holdings;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: header(),
          body: TabBarView(children: [
            components.lists.transactionsView(context,
                showUSD: showUSD,
                transactions: currentTxs.where((tx) =>
                    tx.security.symbol == data['holding']!.security.symbol),
                onLongPress: _toggleUSD,
                msg:
                    '\nNo ${data['holding']!.security.symbol} transactions.\n'),
            _metadataView() ??
                components.lists.emptyMessage(context,
                    icon: Icons.description, msg: '\nNo metadata.\n'),
          ]),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: sendReceiveButtons(),
          //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
        ));
  }

  PreferredSize header() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          elevation: 2,
          centerTitle: false,
          leading: components.buttons.back(context),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: components.buttons.settings(context, () {
                  setState(() {});
                }))
          ],
          title: Text(data['holding']!.security.symbol),
          flexibleSpace: Container(
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 45.0),
                    Container(
                        height: 90,
                        width: 90,
                        child: components.icons
                            .assetAvatar(data['holding']!.security.symbol)),
                    SizedBox(height: 10.0),
                    Text(
                        components.text.securityAsReadable(
                            data['holding']!.value,
                            symbol: data['holding']!.security.symbol),
                        style: Theme.of(context).textTheme.headline3),
                    SizedBox(height: 15.0),
                    Text('\$654.02',
                        style: Theme.of(context).textTheme.headline5),
                  ])),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: TabBar(
                  tabs: [Tab(text: 'Transactions'), Tab(text: 'Metadata')]))));

  /// get metadata from chain or something, store it... need a new reservoir...
  /// interpret it correctly if it is in a recognizable format,
  /// else present file download option
  ListView? _metadataView() {
    return ListView(
        children: [Image(image: AssetImage('assets/magicmusk.png'))]);
    //return null;
  }

  /// different from home.sendReceiveButtons because it prefills the chosen token
  /// receive works the same
  Row sendReceiveButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        components.buttons.receive(context),
        currentHolds.length > 0
            ? components.buttons
                .send(context, symbol: data['holding']!.security.symbol)
            : components.buttons.send(context,
                symbol: data['holding']!.security.symbol, disabled: true),
      ]);
}
