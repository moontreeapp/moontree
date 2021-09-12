import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/text.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/theme/extensions.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/utils/utils.dart';

class WalletView extends StatefulWidget {
  final dynamic data;
  const WalletView({this.data}) : super();

  @override
  _WalletViewState createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  dynamic data = {};
  bool showSecret = false;
  ToolbarOptions toolbarOptions =
      ToolbarOptions(copy: true, selectAll: true, cut: false, paste: false);
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

  void _toggleShow() {
    setState(() {
      showSecret = !showSecret;
    });
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: header(),
            body: body(),
            bottomNavigationBar: RavenButton.bottomNav(context)));
  }

  PreferredSize header() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.25),
      child: AppBar(
          leading: RavenButton.back(context),
          elevation: 2,
          centerTitle: false,
          title: Text('Wallet'),
          flexibleSpace: Container(
            alignment: Alignment.center,
            child: Text(
                '\n\$ ${Current.walletBalanceUSD(data['address']).valueUSD}',
                style: Theme.of(context).textTheme.headline3),
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: TabBar(tabs: [
                Tab(text: 'Details'),
                Tab(text: 'Holdings'),
                Tab(text: 'Transactions')
              ]))));

  TabBarView body() => TabBarView(children: [
        ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(10.0),
            children: <Widget>[
              SizedBox(height: 30.0),
              Center(
                  child: Column(children: <Widget>[
                QrImage(
                    backgroundColor: Colors.white,
                    data: data['address'],
                    semanticsLabel: data['address'],
                    version: QrVersions.auto,
                    size: 200.0),
                SelectableText(data['address'],
                    cursorColor: Colors.grey[850],
                    showCursor: true,
                    style: Theme.of(context).mono,
                    toolbarOptions: toolbarOptions),
                Text('(address)', style: Theme.of(context).annotate),
              ])),
              SizedBox(height: 40.0),
              Text('Warning! Do Not Disclose!',
                  style: TextStyle(color: Theme.of(context).bad)),
              SizedBox(height: 15.0),
              Text(data['secretName'] + ':'),
              Center(
                  child: Visibility(
                      visible: showSecret,
                      child: SelectableText(
                        data['secret'],
                        cursorColor: Colors.grey[850],
                        showCursor: true,
                        style: Theme.of(context).mono,
                        toolbarOptions: toolbarOptions,
                      ))),
              SizedBox(height: 30.0),
              ElevatedButton(
                  onPressed: () => _toggleShow(),
                  child: Text(showSecret
                      ? 'Hide ' + data['secretName']
                      : 'Show ' + data['secretName']))
            ]),
        // holdings, Current.walletHoldings(data['address'])
        holdingsView(),
        // transactions histories.byWallet...
        transactionsView()
      ]);

  ListView holdingsView() {
    var rvnHolding = <Widget>[];
    var assetHoldings = <Widget>[];
    for (var holding in Current.walletHoldings(data['address'])) {
      var thisHolding = ListTile(
          onTap: () => Navigator.pushNamed(context,
              holding.security.symbol == 'RVN' ? '/transactions' : '/asset',
              arguments: {'holding': holding}),
          onLongPress: () => _toggleUSD(),
          leading: RavenIcon.assetAvatar(holding.security.symbol),
          title: Text(holding.security.symbol,
              style: holding.security.symbol == 'RVN'
                  ? Theme.of(context).textTheme.bodyText1
                  : Theme.of(context).textTheme.bodyText2),
          trailing: Text(
              RavenText.securityAsReadable(holding.value,
                  security: holding.security, asUSD: showUSD),
              style: TextStyle(color: Theme.of(context).good)));
      if (holding.security.symbol == 'RVN') {
        rvnHolding.add(thisHolding);

        /// create asset should allow you to create an asset using a speicific address...
        if (holding.value < 600) {
          //rvnHolding.add(ListTile(
          //    onTap: () {},
          //    title: Text('+ Create Asset (not enough RVN)',
          //        style: TextStyle(color: Theme.of(context).disabledColor))));
        } else {
          //rvnHolding.add(ListTile(
          //    onTap: () {},
          //    title: TextButton.icon(
          //        onPressed: () => Navigator.pushNamed(context, '/create'),
          //        icon: Icon(Icons.add),
          //        label: Text('Create Asset'))));
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
      //rvnHolding.add(ListTile(
      //    onTap: () {},
      //    title: Text('+ Create Asset (not enough RVN)',
      //        style: TextStyle(color: Theme.of(context).disabledColor))));
    }

    return ListView(children: <Widget>[...rvnHolding, ...assetHoldings]);
  }

  ListView transactionsView() => ListView(children: <Widget>[
        for (var transaction in Current.walletTransactions(data['address']))
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
                      RavenText.securityAsReadable(transaction.value,
                          security: transaction.security, asUSD: showUSD),
                      style: TextStyle(color: Theme.of(context).good))
                  : Text(
                      RavenText.securityAsReadable(transaction.value,
                          security: transaction.security, asUSD: showUSD),
                      style: TextStyle(color: Theme.of(context).bad))),
              leading: RavenIcon.assetAvatar(transaction.security.symbol))
      ]);
}
