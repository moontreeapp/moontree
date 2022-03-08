/// this file could be removed with slight modifications to transactions.dart
/// that should probably happen at some point - when we start using assets more.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class Transactions extends StatefulWidget {
  final dynamic data;
  const Transactions({this.data}) : super();

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offset;
  Map<String, dynamic> data = {};
  List<StreamSubscription> listeners = [];
  bool showUSD = false;
  late List<TransactionRecord> currentTxs;
  late List<Balance> currentHolds;
  late Security security;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0)).animate(
        CurvedAnimation(
            parent: controller,
            curve: Curves.ease,
            reverseCurve: Curves.ease.flipped));

    listeners.add(res.balances.batchedChanges.listen((batchedChanges) {
      if (batchedChanges.isNotEmpty) setState(() {});
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    controller.dispose();
    super.dispose();
  }

  bool visibilityOfSendReceive(notification) {
    if (notification.direction == ScrollDirection.forward &&
        Backdrop.of(components.navigator.routeContext!).isBackLayerConcealed) {
      Backdrop.of(components.navigator.routeContext!).revealBackLayer();
    } else if (notification.direction == ScrollDirection.reverse &&
        Backdrop.of(components.navigator.routeContext!).isBackLayerRevealed) {
      Backdrop.of(components.navigator.routeContext!).concealBackLayer();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    currentTxs = Current.compiledTransactions;
    currentHolds = Current.holdings;
    security = data['holding']!.security;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: TabBarView(
          controller: components.navigator.tabController,
          children: <Widget>[
            GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child:

                    /// comments: to remove scroll functionality as it is not yet fluid. #182
                    ///NotificationListener<UserScrollNotification>(
                    ///    onNotification: visibilityOfSendReceive,
                    ///    child:
                    TransactionList(
                        transactions: currentTxs.where(
                            (tx) => tx.security.symbol == security.symbol),
                        msg: '\nNo ${security.symbol} transactions.\n')),

            ///),
            _metadataView() ??
                components.empty.message(
                  context,
                  icon: Icons.description,
                  msg: '\nNo metadata.\n',
                ),
          ]),
      floatingActionButton: SlideTransition(position: offset, child: NavBar()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );

    /// no place to view metadata right now - this used to be tabs
  }

  Widget? _metadataView() {
    var securityAsset = security.asset;
    if (securityAsset == null || securityAsset.hasMetadata == false) {
      return null;
    }
    var chilren = <Widget>[];
    if (securityAsset.primaryMetadata == null && securityAsset.hasIpfs) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
                child: Text('VIEW DATA', //Text('${securityAsset.metadata}',
                    style: Theme.of(context).viewData),
                onTap: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                            title: Text('Open in External App'),
                            content: Text('Open ipfs data in browser?'),
                            actions: [
                              TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () => Navigator.of(context).pop()),
                              TextButton(
                                  child: Text('Continue'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    launch(
                                        'https://ipfs.io/ipfs/${securityAsset.metadata}');
                                  })
                            ])))
          ]);
    } else if (securityAsset.primaryMetadata == null) {
      chilren = [SelectableText(securityAsset.metadata)];
    } else if (securityAsset.primaryMetadata!.kind == MetadataType.ImagePath) {
      chilren = [
        Image.file(AssetLogos()
            .readImageFileNow(securityAsset.primaryMetadata!.data ?? ''))
      ];
    } else if (securityAsset.primaryMetadata!.kind == MetadataType.JsonString) {
      chilren = [SelectableText(securityAsset.primaryMetadata!.data ?? '')];
    } else if (securityAsset.primaryMetadata!.kind == MetadataType.Unknown) {
      chilren = [
        SelectableText(securityAsset.primaryMetadata!.metadata),
        SelectableText(securityAsset.primaryMetadata!.data ?? '')
      ];
    }
    return ListView(padding: EdgeInsets.all(10.0), children: chilren);
  }
}
