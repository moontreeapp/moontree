import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ravencoin_back/services/transaction/transaction.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/components/status.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/utils/data.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class WalletView extends StatefulWidget {
  final dynamic data;
  const WalletView({Key? key, this.data}) : super(key: key);

  @override
  _WalletViewState createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  Map<String, dynamic> data = <String, dynamic>{};
  bool disabled = false;
  bool showSecret = false;
  ToolbarOptions toolbarOptions =
      const ToolbarOptions(copy: true, selectAll: true);
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

  //void _toggleShow() {
  //  setState(() {
  //    showSecret = !showSecret;
  //  });
  //}

  bool visibilityOfSendReceive(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.forward) {
      if (!isFabVisible) {
        setState(() => isFabVisible = true);
      }
    } else if (notification.direction == ScrollDirection.reverse) {
      if (isFabVisible) {
        setState(() => isFabVisible = false);
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    secret = data['secret'] as String? ?? '';
    data['secretName'] = SecretType.mnemonic;
    secretName = (data['secretName'] as SecretType)
        .name
        .toTitleCase(underscoresAsSpace: true);
    wallet = data['wallet'] = Current.wallet;
    walletType = wallet is LeaderWallet ? 'LeaderWallet' : 'SingleWallet';
    wallet = wallet is LeaderWallet
        ? data['wallet'] as LeaderWallet
        : data['wallet'] as SingleWallet;
    if (wallet.cipher != null) {
      address ??= wallet is LeaderWallet
          ? services.wallet
              .getEmptyAddress(wallet as LeaderWallet, NodeExposure.external)
          : wallet.addresses.first.address;
      //services.wallet.single.getKPWallet(wallet as SingleWallet).address;
    }
    disabled = Current.holdings.isEmpty;
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          //appBar: header(),
          body: body(),
          //floatingActionButtonLocation:
          //    FloatingActionButtonLocation.centerFloat,
          //floatingActionButton: isFabVisible ? sendButton() : null,
        ));
  }

  PreferredSize header() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.20),
      child: AppBar(
          leading: components.buttons.back(context),
          elevation: 2,
          centerTitle: false,
          title: const Text('Wallet'),
          actions: <AppLifecycleReactor>[components.status],
          flexibleSpace: Container(
            alignment: const Alignment(0.0, -0.5),
            child: const Text(
              '\n Current.balanceUSD?.valueUSD ?? Current.balanceRVN.value',
            ),
          ),
          bottom: const PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: TabBar(tabs: <Widget>[
                Tab(text: 'Details'),
                Tab(text: 'Holdings'),
                Tab(text: 'Transactions')
              ]))));

  TabBarView body() => TabBarView(children: <Widget>[
        detailsView(),
        NotificationListener<UserScrollNotification>(
            onNotification: visibilityOfSendReceive,
            child: HoldingList(
              holdings: holdings ?? Current.holdings,
              scrollController: ScrollController(),
            )),
        NotificationListener<UserScrollNotification>(
            onNotification: visibilityOfSendReceive,
            child: TransactionList(
                transactions:
                    transactions ?? Current.walletCompiledTransactions())),
      ]);

  ListView detailsView() => ListView(
          shrinkWrap: true,
          controller: _scrollController,
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            /*
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
            */
            const Text('Wallet Addresses'),
            const SizedBox(height: 10.0),
            Center(
              child: Column(
                children: <Widget>[
                  if (address != null)
                    QrImage(
                        backgroundColor: Colors.white,
                        data: address!,
                        semanticsLabel: address!,
                        //version: QrVersions.auto,
                        size: 200.0)
                  else
                    const Text(
                        'QR code unrenderable since wallet cannot be decrypted. Please login again.'),
                  const SizedBox(height: 10.0),
                  if (address != null)
                    SelectableText(address!,
                        cursorColor: Colors.grey[850],
                        showCursor: true,
                        toolbarOptions: toolbarOptions)
                  else
                    const Text(
                        'address unknown since wallet cannot be decrypted. Please login again.'),
                  const SizedBox(height: 10.0),
                  exposureAndIndex,
                  //Text('$' + addressBalance), //that seemed to take just as long...
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            ...addressesView(),
            const SizedBox(height: 30.0),
          ]);

  List<Widget> addressesView() => wallet is LeaderWallet
      ? <Widget>[
          for (Address walletAddress
              in wallet.addressesFor()
                ..sort((Address a, Address b) => a.compareTo(b)))
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
              onTap: () => setState(() {
                // Delay to make sure the frames are rendered properly
                //await Future<void>.delayed(const Duration(milliseconds: 300));

                _scrollController.animateTo(
                    _scrollController.position.minScrollExtent,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn);

                transactions = Current.walletCompiledTransactions()
                    //.where((transactionRecord) =>
                    //    transactionRecord.fromAddress ==
                    //        walletAddress.address ||
                    //    transactionRecord.toAddress ==
                    //        walletAddress.address)
                    .toList();
                address = walletAddress.address;
                //privateKey = (await services.wallet.leader
                //        .getSubWalletFromAddress(walletAddress))
                //    .wif; // .wif is the format that raven-Qt-testnet expects
                //.base58Priv;
                //.privKey;
                exposureAndIndex = Column(children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        'Index: ${walletAddress.hdIndex}',
                      ),
                      Text(
                        walletAddress.exposure.name.toTitleCase(),
                      ),
                      Text(
                          'Balance: ${satToAmount(services.transaction.walletUnspents(wallet).where((Vout vout) => vout.toAddress == walletAddress.address).map((Vout vout) => vout.coinValue).toList().sumInt())}',
                          style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                  /*
                  SizedBox(height: 10),
                  SelectableText(
                    'private key: ' + (privateKey ?? 'unknown'),
                  ),
                  */
                ]);
              }),
              leading: walletAddress.exposure == NodeExposure.internal
                  ? components.icons.out(context)
                  : components.icons.income(context),
              title: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(walletAddress.address,
                      style: pros.vouts.byAddress
                              .getAll(walletAddress.address)
                              .isNotEmpty
                          ? Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(fontWeight: FontWeight.bold)
                          : Theme.of(context).textTheme.caption)),

              trailing: Text(
                  satToAmount(services.transaction
                          .walletUnspents(wallet)
                          .where((Vout vout) =>
                              vout.toAddress == walletAddress.address)
                          .map((Vout vout) => vout.coinValue)
                          .toList()
                          .sumInt())
                      .toString(),
                  style: Theme.of(context).textTheme.caption),
              //trailing: Text('address.value'),
              //trailing: (address.value > 0
              //    ? Text(
              //        services.conversion.securityAsReadable(transaction.value,
              //            security: transaction.security, asUSD: showUSD),
              //        style: TextStyle(color: Theme.of(context).good))
              //    : Text(
              //        services.conversion.securityAsReadable(transaction.value,
              //            security: transaction.security, asUSD: showUSD),
              //        style: TextStyle(color: Theme.of(context).bad))),
              //leading: components.icons.assetAvatar(transaction.security.symbol)
            )
        ]
      : <Widget>[
          ListTile(
              onTap: () {},
              onLongPress: () {},
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(address ?? '',
                        style: Theme.of(context).textTheme.caption),
                    components.icons.income(context),
                    components.icons.out(context),
                  ]))
        ];

  ElevatedButton sendButton() => ElevatedButton.icon(
        icon: const Icon(Icons.north_east),
        label: const Text('Send'),
        onPressed: disabled
            ? () {}
            : () => Navigator.pushNamed(context, '/transaction/send',
                    arguments: {
                      'symbol': pros.securities.currentCoin.symbol,
                      'walletId': wallet.id
                    }),
      );
}
