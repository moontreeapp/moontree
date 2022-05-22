import 'dart:async';

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction/transaction.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:rxdart/rxdart.dart';

TransactionsBloc get transactionsBloc => TransactionsBloc.instance();

class TransactionsBloc {
  TransactionsBloc._();

  factory TransactionsBloc.instance() {
    return _instance ??= TransactionsBloc._();
  }

  reset() {
    scrollObserver.close();
    currentTab.close();
    _instance = null;
    return TransactionsBloc.instance();
  }

  static TransactionsBloc? _instance;
  Map<String, dynamic> data = {};
  BehaviorSubject<double> scrollObserver = BehaviorSubject.seeded(.91);
  BehaviorSubject<String> currentTab = BehaviorSubject.seeded('HISTORY');

  double getOpacityFromController(
      double controllerValue, double minHeightFactor) {
    double opacity = 1;
    if (controllerValue >= 0.9)
      opacity = 0;
    else if (controllerValue <= minHeightFactor)
      opacity = 1;
    else
      opacity = (0.9 - controllerValue) * 5;
    return opacity;
  }

  bool get nullCacheView {
    var securityAsset = security.asset;
    return securityAsset == null || securityAsset.hasMetadata == false;
  }

  Security get security => data['holding']!.security;
  List<Balance> get currentHolds => Current.holdings;
  List<TransactionRecord> get currentTxs => services.transaction
      .getTransactionRecords(wallet: Current.wallet, securities: {security});
}
