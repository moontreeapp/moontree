/// this file could be removed with slight modifications to transactions.dart
/// that should probably happen at some point - when we start using assets more.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction.dart';
import 'package:raven_front/services/ipfs.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/utils/utils.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/indicators/indicators.dart';
import 'package:raven_front/widgets/widgets.dart';

class Asset extends StatefulWidget {
  final dynamic data;
  const Asset({this.data}) : super();

  @override
  _AssetState createState() => _AssetState();
}

class _AssetState extends State<Asset> {
  Map<String, dynamic> data = {};
  bool showUSD = false;
  late List<TransactionRecord> currentTxs;
  late List<Balance> currentHolds;
  bool isFabVisible = true;
  Security? security;

  @override
  void initState() {
    super.initState();
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
    currentTxs = data.containsKey('walletId') && data['walletId'] != null
        ? Current.walletCompiledTransactions(data['walletId'])
        : Current.compiledTransactions;
    currentHolds = data.containsKey('walletId') && data['walletId'] != null
        ? Current.walletHoldings(data['walletId'])
        : Current.holdings;
    security = data['holding']!.security;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: header(),
          body: TabBarView(children: <Widget>[
            NotificationListener<UserScrollNotification>(
                onNotification: visibilityOfSendReceive,
                child: TransactionList(
                    transactions: currentTxs.where((tx) =>
                        tx.security.symbol == data['holding']!.security.symbol),
                    msg:
                        '\nNo ${data['holding']!.security.symbol} transactions.\n')),
            _metadataView() ??
                components.empty.message(
                  context,
                  icon: Icons.description,
                  msg: '\nNo metadata.\n',
                ),
          ]),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: isFabVisible ? sendReceiveButtons() : null,
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
            components.status,
            indicators.process,
            indicators.client,
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: components.buttons.settings(context))
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
                  ])),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: TabBar(
                  tabs: [Tab(text: 'Transactions'), Tab(text: 'Metadata')]))));

  /// get metadata from chain or something, store it... need a new reservoir...
  /// interpret it correctly if it is in a recognizable format,
  /// else present file download option
  ListView? _metadataView() {
    // TODO we're not allowed to use future calls in build so we can't check to see if a file exists.
    // so to display an image we need to have an in memory global service that tells us what files are available
    //if (security!.asset!.hasMetadata) {
    //  if (security!.asset!.hasIpfs) {
    //    var explorer = IpfsMiniExplorer(security!.asset!.metadata);
    //    var content = await explorer.get(); // Oops! this must be a waiter which pre-pulls the data and saves it in a reservoir!
    //    if (explorer.responseType == ResponseType.imagePath) {
    //      return ListView(children: [Image.file(File(content))]);
    //    }
    //    if (explorer.responseType == ResponseType.jsonString) {
    //      return ListView(children: [SelectableText(security!.asset!.metadata ?? '')])
    //    }
    //  }
    //  return ListView(children: [SelectableText(security!.asset!.metadata ?? '')]);
    //}
    return (security?.asset?.hasMetadata ?? false)
        //? await AssetLogos().readLogoFileNow(security!.metadata ?? '', settings.localPath!).exists()
        ? ListView(children: [SelectableText(security?.asset?.metadata ?? '')])
        //  : null
        : null;
    ////return ListView(
    ////    children: [Image(image: AssetImage('assets/magicmusk.png'))]);
    ////return null;
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
