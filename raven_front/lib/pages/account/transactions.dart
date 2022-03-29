/// this file could be removed with slight modifications to transactions.dart
/// that should probably happen at some point - when we start using assets more.

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/streams/spend.dart';
//import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/theme/theme.dart';
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
    with TickerProviderStateMixin {
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

  //bool visibilityOfSendReceive(notification) {
  //  if (notification.direction == ScrollDirection.forward &&
  //      Backdrop.of(components.navigator.routeContext!).isBackLayerConcealed) {
  //    Backdrop.of(components.navigator.routeContext!).revealBackLayer();
  //  } else if (notification.direction == ScrollDirection.reverse &&
  //      Backdrop.of(components.navigator.routeContext!).isBackLayerRevealed) {
  //    Backdrop.of(components.navigator.routeContext!).concealBackLayer();
  //  }
  //  return true;
  //}

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    security = data['holding']!.security;
    currentHolds = Current.holdings;
    currentTxs = services.transaction
        .getTransactionRecords(wallet: Current.wallet, securities: {security});
    var back = BalanceHeader(pageTitle: 'Transactions');
    //components.navigator.tabController = components.navigator.tabController ??
    //    TabController(length: 2, vsync: this);
    var minHeight = 1 - (201 + 16) / MediaQuery.of(context).size.height;
    return BackdropLayers(
      back: back, // must be created first
      front: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          /// struggling to get Tabs to work (makes back area unresponsive)...
          /// we could simply rebuild this with the corresponding stuff rather
          /// than using tab view...
          //TabBarView(
          //    controller: components.navigator.tabController,
          //    dragStartBehavior: DragStartBehavior.down,
          //    children: <Widget>[
          DraggableScrollableSheet(
              initialChildSize: minHeight,
              minChildSize: minHeight,
              maxChildSize: 1.0,
              builder: ((context, scrollController) {
                return FrontCurve(
                    frontLayerBoxShadow: [],
                    child: TransactionList(
                        scrollController: scrollController,
                        transactions: currentTxs.where(
                            (tx) => tx.security.symbol == security.symbol),
                        msg: '\nNo ${security.symbol} transactions.\n'));
              })),
          //_metadataView() ??
          //    components.empty.message(
          //      context,
          //      icon: Icons.description,
          //      msg: '\nNo metadata.\n',
          //    ),
          //]),
          NavBar(),
        ],
      ),
    );
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
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontWeight: FontWeights.bold,
                        letterSpacing: 1.25,
                        color: AppColors.primary)),
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
