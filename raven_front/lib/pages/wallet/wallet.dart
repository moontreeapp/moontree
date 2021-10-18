import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raven/utils/transform.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/styles/buttons.dart';
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
  bool disabled = false;
  bool showSecret = false;
  ToolbarOptions toolbarOptions =
      ToolbarOptions(copy: true, selectAll: true, cut: false, paste: false);
  bool showUSD = false;
  late Wallet wallet;
  late String walletType;
  String? address;
  //String addressBalance = '';
  Row exposureAndIndex = Row();

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
    wallet = data['wallet'];
    walletType = wallet.humanTypeKey == LingoKey.leaderWalletType
        ? 'LeaderWallet'
        : 'SingleWallet';
    wallet = wallet.humanTypeKey == LingoKey.leaderWalletType
        ? data['wallet'] as LeaderWallet
        : data['wallet'] as SingleWallet;
    if (wallet.cipher != null) {
      address = address ??
          (wallet.humanTypeKey == LingoKey.leaderWalletType
              ? services.wallets.leaders
                  .getNextEmptyWallet(wallet as LeaderWallet,
                      exposure: NodeExposure.External)
                  .address
              : services.wallets.singles
                  .getKPWallet(wallet as SingleWallet)
                  .address);
    } else {
      address = address ?? null;
    }
    disabled = Current.walletHoldings(wallet.walletId).length == 0;
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: header(),
            body: body(),

            /// hidden for beta
            //floatingActionButtonLocation:
            //    FloatingActionButtonLocation.centerFloat,
            //floatingActionButton: sendButton(),
            bottomNavigationBar: RavenButton.bottomNav(context)));
  }

  PreferredSize header() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.20),
      child: AppBar(
          leading: RavenButton.back(context),
          elevation: 2,
          centerTitle: false,
          title: Text('Wallet'),
          flexibleSpace: Container(
            alignment: Alignment(0.0, -0.5),
            child: Text(
                '\n\$ ${Current.walletBalanceUSD(wallet.walletId).valueUSD}',
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
        detailsView(),
        // holdings, Current.walletHoldings(wallet.walletId)
        holdingsView(),
        // transactions histories.byWallet...
        transactionsView()
      ]);

  ListView detailsView() =>
      ListView(shrinkWrap: true, padding: EdgeInsets.all(20.0), children: <
          Widget>[
        Text('WARNING!\nDo NOT disclose the Mnemonic Secret to anyone!',
            style: TextStyle(color: Theme.of(context).bad)),
        SizedBox(height: 15.0),
        Text(data['secretName'] + ' Secret:'),
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
                ? 'Hide ' + data['secretName'] + ' Secret'
                : 'Show ' + data['secretName'] + ' Secret')),
        SizedBox(height: 30.0),
        Text('Wallet Addresses', style: Theme.of(context).textTheme.headline4),
        SizedBox(height: 10.0),
        Center(
          child: Column(
            children: <Widget>[
              address != null
                  ? QrImage(
                      backgroundColor: Colors.white,
                      data: address!,
                      semanticsLabel: address!,
                      version: QrVersions.auto,
                      size: 200.0)
                  : Text(
                      'QR code unrenderable since wallet cannto be decrypted.'),
              address != null
                  ? SelectableText(address!,
                      cursorColor: Colors.grey[850],
                      showCursor: true,
                      style: Theme.of(context).mono,
                      toolbarOptions: toolbarOptions)
                  : Text('address unknown since wallet cannto be decrypted.'),
              SizedBox(height: 5.0),
              exposureAndIndex,
              //Text('$' + addressBalance), //that seemed to take just as long...
            ],
          ),
        ),
        SizedBox(height: 30.0),
        ...addressesView(),
        SizedBox(height: 30.0),
      ]);

  List<Widget> addressesView() =>
      wallet.humanTypeKey == LingoKey.leaderWalletType
          ? [
              for (var walletAddress
                  in wallet.addresses..sort((a, b) => a.compareTo(b)))
                ListTile(
                  onTap: () => setState(() {
                    address = walletAddress.address;
                    //addressBalance = RavenText.satsToAmount(histories
                    //        .byScripthash
                    //        .getAll(walletAddress.scripthash)
                    //        .map((History history) => history.value)
                    //        .toList()
                    //        .sumInt() as int)
                    //    .toString();
                    exposureAndIndex = Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Index: ' + walletAddress.hdIndex.toString(),
                            style: Theme.of(context).annotate),
                        Text(
                            (walletAddress.exposure == NodeExposure.Internal
                                ? 'Internal (change)'
                                : 'External (receive)'),
                            style: Theme.of(context).annotate),
                        Text(
                            'Balance: ' +
                                RavenText.satsToAmount(transactions.byScripthash
                                        .getAll(walletAddress.scripthash)
                                        .map((Transaction tx) => tx.value)
                                        .toList()
                                        .sumInt())
                                    .toString(),
                            style: Theme.of(context).textTheme.caption),
                      ],
                    );
                  }),
                  title: Wrap(alignment: WrapAlignment.spaceBetween, children: [
                    (walletAddress.exposure == NodeExposure.Internal
                        ? RavenIcon.out(context)
                        : RavenIcon.income(context)),
                    Text(walletAddress.address,
                        style: Theme.of(context).textTheme.caption),
                    Text(
                        // I thoguht this is what slows down loading the page, but I now think it's the qr code... //takes a few seconds, lets just get them one at a time in onTap
                        RavenText.satsToAmount(transactions.byScripthash
                                .getAll(walletAddress.scripthash)
                                .map((Transaction history) => history.value)
                                .toList()
                                .sumInt() as int)
                            .toString(),
                        style: Theme.of(context).textTheme.caption),
                  ]),
                  //trailing: Text('address.value'),
                  //trailing: (address.value > 0
                  //    ? Text(
                  //        RavenText.securityAsReadable(transaction.value,
                  //            security: transaction.security, asUSD: showUSD),
                  //        style: TextStyle(color: Theme.of(context).good))
                  //    : Text(
                  //        RavenText.securityAsReadable(transaction.value,
                  //            security: transaction.security, asUSD: showUSD),
                  //        style: TextStyle(color: Theme.of(context).bad))),
                  //leading: RavenIcon.assetAvatar(transaction.security.symbol)
                )
            ]
          : [
              ListTile(
                  onTap: () {},
                  onLongPress: () {},
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(address ?? '',
                            style: Theme.of(context).textTheme.caption),
                        RavenIcon.income(context),
                        RavenIcon.out(context),
                      ]))
            ];

  ListView holdingsView() {
    var rvnHolding = <Widget>[];
    var assetHoldings = <Widget>[];
    for (var holding in Current.walletHoldings(wallet.walletId)) {
      var thisHolding = ListTile(
          onTap: () => Navigator.pushNamed(context,
              holding.security.symbol == 'RVN' ? '/transactions' : '/asset',
              arguments: {'holding': holding, 'walletId': wallet.walletId}),
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
          rvnHolding.add(ListTile(
              onTap: () {},
              title: TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/create',
                      arguments: {'walletId': wallet.walletId}),
                  icon: Icon(Icons.add),
                  label: Text('Create Asset'))));
        }
      } else {
        assetHoldings.add(thisHolding);
      }
    }
    if (rvnHolding.isEmpty) {
      rvnHolding.add(ListTile(
          onTap: () {},
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
        for (var transaction
            in Current.walletCompiledTransactions(wallet.walletId))
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

  ElevatedButton sendButton() => ElevatedButton.icon(
      icon: Icon(Icons.north_east),
      label: Text('Send'),
      onPressed: disabled
          ? () {}
          : () => Navigator.pushNamed(context, '/send',
              arguments: {'symbol': 'RVN', 'walletId': wallet.walletId}),
      style: disabled
          ? RavenButtonStyle.disabledCurvedSides(context)
          : RavenButtonStyle.curvedSides);
}
