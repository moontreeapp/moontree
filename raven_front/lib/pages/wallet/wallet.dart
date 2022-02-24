import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raven_back/services/transaction.dart';
import 'package:raven_back/extensions/list.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:raven_back/extensions/string.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/indicators/indicators.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';

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
  late String secret;
  late String secretName;
  late Wallet wallet;
  late String walletType;
  String? address;
  String? privateKey;
  //String addressBalance = '';
  Widget exposureAndIndex = Row();
  List<Balance>? holdings;
  List<TransactionRecord>? transactions;
  bool isFabVisible = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void _toggleShow() {
    setState(() {
      showSecret = !showSecret;
    });
  }

  bool visibilityOfSendReceive(notification) {
    if (notification.direction == ScrollDirection.forward) {
      if (!isFabVisible) setState(() => isFabVisible = true);
    } else if (notification.direction == ScrollDirection.reverse) {
      if (isFabVisible) setState(() => isFabVisible = false);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    secret = data['secret'];
    secretName = (data['secretName'] as SecretType)
        .enumString
        .toTitleCase(underscoreAsSpace: true);
    wallet = data['wallet'];
    walletType = wallet is LeaderWallet ? 'LeaderWallet' : 'SingleWallet';
    wallet = wallet is LeaderWallet
        ? data['wallet'] as LeaderWallet
        : data['wallet'] as SingleWallet;
    if (wallet.cipher != null) {
      address = address ??
          (wallet is LeaderWallet
              ? services.wallet.leader
                  .getNextEmptyWallet(wallet as LeaderWallet,
                      exposure: NodeExposure.External)
                  .address
              : services.wallet.single
                  .getKPWallet(wallet as SingleWallet)
                  .address);
    } else {
      address = address ?? null;
    }
    disabled = Current.holdings.length == 0;
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          //appBar: header(),
          body: body(),
          //floatingActionButtonLocation:
          //    FloatingActionButtonLocation.centerFloat,
          //floatingActionButton: isFabVisible ? sendButton() : null,

          /// hidden for beta
          //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
        ));
  }

  PreferredSize header() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.20),
      child: AppBar(
          leading: components.buttons.back(context),
          elevation: 2,
          centerTitle: false,
          title: Text('Wallet'),
          actions: [
            components.status,
            indicators.process,
            indicators.client,
          ],
          flexibleSpace: Container(
            alignment: Alignment(0.0, -0.5),
            child: Text(
                '\n ${Current.balanceUSD?.valueUSD ?? Current.balanceRVN.value}',
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
        NotificationListener<UserScrollNotification>(
            onNotification: visibilityOfSendReceive,
            child: HoldingList(holdings: holdings ?? Current.holdings)),
        NotificationListener<UserScrollNotification>(
            onNotification: visibilityOfSendReceive,
            child: TransactionList(
                transactions:
                    transactions ?? Current.walletCompiledTransactions())),
      ]);

  ListView detailsView() => ListView(
          shrinkWrap: true,
          controller: _scrollController,
          padding: EdgeInsets.all(20.0),
          children: <Widget>[
            Text('WARNING!\nDo NOT disclose the Mnemonic Secret to anyone!',
                style: TextStyle(color: Theme.of(context).bad)),
            SizedBox(height: 15.0),
            Text(secretName + ' Secret:'),
            Center(
                child: Visibility(
              visible: showSecret,
              child: SelectableText(
                secret,
                cursorColor: Colors.grey[850],
                showCursor: true,
                style: Theme.of(context).mono,
                toolbarOptions: toolbarOptions,
              ),
            )),
            SizedBox(height: 30.0),
            ElevatedButton(
                onPressed: () => _toggleShow(),
                child: Text(showSecret
                    ? 'Hide ' + secretName + ' Secret'
                    : 'Show ' + secretName + ' Secret')),
            SizedBox(height: 30.0),
            Text('Wallet Addresses',
                style: Theme.of(context).textTheme.headline4),
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
                          'QR code unrenderable since wallet cannot be decrypted. Please login again.'),
                  SizedBox(height: 10.0),
                  address != null
                      ? SelectableText(address!,
                          cursorColor: Colors.grey[850],
                          showCursor: true,
                          style: Theme.of(context).mono,
                          toolbarOptions: toolbarOptions)
                      : Text(
                          'address unknown since wallet cannot be decrypted. Please login again.'),
                  SizedBox(height: 10.0),
                  exposureAndIndex,
                  //Text('$' + addressBalance), //that seemed to take just as long...
                ],
              ),
            ),
            SizedBox(height: 30.0),
            ...addressesView(),
            SizedBox(height: 30.0),
          ]);

  List<Widget> addressesView() => wallet is LeaderWallet
      ? [
          for (var walletAddress
              in wallet.addresses..sort((a, b) => a.compareTo(b)))
            ListTile(
              onTap: () => setState(() {
                // Delay to make sure the frames are rendered properly
                //await Future.delayed(const Duration(milliseconds: 300));

                _scrollController.animateTo(
                    _scrollController.position.minScrollExtent,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn);

                //holdings = services.balance.addressesBalances([walletAddress]);
                transactions = Current.walletCompiledTransactions()
                    //.where((transactionRecord) =>
                    //    transactionRecord.fromAddress ==
                    //        walletAddress.address ||
                    //    transactionRecord.toAddress ==
                    //        walletAddress.address)
                    .toList();
                address = walletAddress.address;
                privateKey = services.wallet.leader
                    .getSubWalletFromAddress(walletAddress)
                    .wif; // .wif is the format that raven-Qt-testnet expects
                //.base58Priv;
                //.privKey;
                exposureAndIndex = Column(children: [
                  Row(
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
                              utils
                                  .satToAmount(services.transaction
                                      .walletUnspents(wallet)
                                      .where((vout) =>
                                          vout.toAddress ==
                                          walletAddress.address)
                                      .map((vout) => vout.rvnValue)
                                      .toList()
                                      .sumInt())
                                  .toString(),
                          style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                  SizedBox(height: 10),
                  SelectableText('private key: ' + (privateKey ?? 'unknown'),
                      style: Theme.of(context).annotate),
                ]);
              }),
              title: Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  (walletAddress.exposure == NodeExposure.Internal
                      ? components.icons.out(context)
                      : components.icons.income(context)),
                  Text(walletAddress.address,
                      style: res.vouts.byAddress
                              .getAll(walletAddress.address)
                              .isNotEmpty
                          ? Theme.of(context)
                              .textTheme
                              .caption!
                              .replace(fontWeight: FontWeight.bold)
                          : Theme.of(context).textTheme.caption),
                  Text(
                      utils
                          .satToAmount(services.transaction
                              .walletUnspents(wallet)
                              .where((vout) =>
                                  vout.toAddress == walletAddress.address)
                              .map((vout) => vout.rvnValue)
                              .toList()
                              .sumInt())
                          .toString(),
                      style: Theme.of(context).textTheme.caption),
                ],
              ),
              //trailing: Text('address.value'),
              //trailing: (address.value > 0
              //    ? Text(
              //        components.text.securityAsReadable(transaction.value,
              //            security: transaction.security, asUSD: showUSD),
              //        style: TextStyle(color: Theme.of(context).good))
              //    : Text(
              //        components.text.securityAsReadable(transaction.value,
              //            security: transaction.security, asUSD: showUSD),
              //        style: TextStyle(color: Theme.of(context).bad))),
              //leading: components.icons.assetAvatar(transaction.security.symbol)
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
                    components.icons.income(context),
                    components.icons.out(context),
                  ]))
        ];

  ElevatedButton sendButton() => ElevatedButton.icon(
      icon: Icon(Icons.north_east),
      label: Text('Send'),
      onPressed: disabled
          ? () {}
          : () => Navigator.pushNamed(context, '/transaction/send',
              arguments: {'symbol': 'RVN', 'walletId': wallet.walletId}),
      style: disabled
          ? components.styles.buttons.disabledCurvedSides(context)
          : components.styles.buttons.curvedSides);
}
