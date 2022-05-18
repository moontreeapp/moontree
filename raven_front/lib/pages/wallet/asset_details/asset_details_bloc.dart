import 'dart:async';

import '../../../utils/data.dart';
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction/transaction.dart';
import 'package:raven_front/pages/wallet/asset_details/assset_details_components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

AssetDetailsBloc get assetDetailsBloc => AssetDetailsBloc.instance();

class AssetDetailsBloc {
  AssetDetailsBloc._() {
    init();
  }

  void init() {
    listeners.add(res.balances.batchedChanges.listen((batchedChanges) {}));
    listeners.add(streams.app.coinspec.listen((String? value) {
      if (value != null) {
        assetDetailsBloc.tabChoice = value;
        streams.app.coinspec.add(null);
      }
    }));
  }

  factory AssetDetailsBloc.instance() {
    return _instance ??= AssetDetailsBloc._();
  }

  reset() {
    for (var listener in assetDetailsBloc.listeners) {
      listener.cancel();
    }
    _instance = null;
    return AssetDetailsBloc.instance();
  }

  static AssetDetailsBloc? _instance;
  Map<String, dynamic> data = {};
  BehaviorSubject<double> scrollObserver = BehaviorSubject.seeded(.91);
  String tabChoice = 'HISTORY';
  List<StreamSubscription> listeners = [];

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

  Security get security => data['holding']!.security;
  List<Balance> get currentHolds => Current.holdings;
  List<TransactionRecord> get currentTxs => services.transaction
      .getTransactionRecords(wallet: Current.wallet, securities: {security});
}
