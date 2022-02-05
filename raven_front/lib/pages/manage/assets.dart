/// a page to view details of an asset or a subasset, including a list of subassets

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

class Asset extends StatefulWidget {
  final dynamic data;
  const Asset({this.data}) : super();

  @override
  _AssetState createState() => _AssetState();
}

class _AssetState extends State<Asset> with SingleTickerProviderStateMixin {
  Map<String, dynamic> data = {};
  List<StreamSubscription> listeners = [];
  late AnimationController controller;
  late Animation<Offset> offset;
  late List<TransactionRecord> currentTxs;
  late List<Balance> currentHolds;

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

    /// listen for new subassets??
    //listeners.add(res.balances.batchedChanges.listen((batchedChanges) {
    //  if (batchedChanges.isNotEmpty) setState(() {});
    //}));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
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
    currentTxs = data.containsKey('walletId') && data['walletId'] != null
        ? Current.walletCompiledTransactions(data['walletId'])
        : Current.compiledTransactions;
    currentHolds = data.containsKey('walletId') && data['walletId'] != null
        ? Current.walletHoldings(data['walletId'])
        : Current.holdings;
    var symbol = data['symbol'] as String;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body:
          //TabBarView(
          //    controller: components.navigator.tabController,
          //    children: <Widget>[
          GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child:

                  /// comments: to remove scroll functionality as it is not yet fluid. #182
                  ///NotificationListener<UserScrollNotification>(
                  ///    onNotification: visibilityOfSendReceive,
                  ///    child:

                  SubAssetList(symbol: symbol))
      //,
      ///),
      //])
      ,
      floatingActionButton: SlideTransition(position: offset, child: NavBar()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
