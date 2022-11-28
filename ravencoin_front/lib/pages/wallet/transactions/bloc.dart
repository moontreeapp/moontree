import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/transaction/transaction.dart';
import 'package:ravencoin_front/services/lookup.dart';
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
  BehaviorSubject<double> scrollObserver = BehaviorSubject.seeded(.7);
  BehaviorSubject<String> currentTab = BehaviorSubject.seeded('HISTORY');
  List<TransactionRecord>? currentTxsCache;

  double getOpacityFromController(
    double controllerValue,
    double minHeightFactor,
  ) {
    double opacity = 1;
    if (controllerValue >= 0.9) {
      opacity = 0;
    } else if (controllerValue <= minHeightFactor) {
      opacity = 1;
    } else {
      opacity = (0.9 - controllerValue) * 5;
    }
    if (opacity > 1) {
      return 1;
    }
    if (opacity < 0) {
      return 0;
    }
    return opacity;
  }

  bool get nullCacheView {
    var securityAsset = security.asset;
    return securityAsset == null || securityAsset.hasMetadata == false;
  }

  Security get security =>
      data['holding']?.security ?? pros.securities.currentCoin;
  List<Balance> get currentHolds => Current.holdings;
  List<TransactionRecord> get currentTxs {
    if (Current.wallet.minerMode) return [];
    if (currentTxsCache == null) {
      currentTxsCache = services.transaction.getTransactionRecords(
          wallet: Current.wallet, securities: {security});
    }
    return currentTxsCache!;
  }

  void clearCache() => currentTxsCache = null;
}
