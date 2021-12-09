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

  ListView? _metadataView() {
    if (security?.asset?.hasMetadata == null ||
        security?.asset?.hasMetadata == false) {
      return null;
    }
    var chilren = <Widget>[];
    if (security?.asset?.primaryMetadata == null) {
      chilren = [SelectableText(security?.asset?.metadata ?? '')];
    } else if (security?.asset?.primaryMetadata!.kind ==
        MetadataType.ImagePath) {
      chilren = [
        Image.file(AssetLogos()
            .readImageFileNow(security?.asset?.primaryMetadata!.data ?? ''))
      ];
    } else if (security?.asset?.primaryMetadata!.kind ==
        MetadataType.JsonString) {
      chilren = [SelectableText(security?.asset?.primaryMetadata!.data ?? '')];
    } else if (security?.asset?.primaryMetadata!.kind == MetadataType.Unknown) {
      chilren = [
        SelectableText(security?.asset?.primaryMetadata!.metadata ?? ''),
        SelectableText(security?.asset?.primaryMetadata!.data ?? '')
      ];
    }
    return ListView(padding: EdgeInsets.all(10.0), children: chilren);
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
