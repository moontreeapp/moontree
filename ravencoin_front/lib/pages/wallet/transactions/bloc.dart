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

  TransactionsBloc reset() {
    scrollObserver.close();
    currentTab.close();
    _instance = null;
    return TransactionsBloc.instance();
  }

  static TransactionsBloc? _instance;
  Map<String, dynamic> data = <String, dynamic>{};
  BehaviorSubject<double> scrollObserver = BehaviorSubject<double>.seeded(.7);
  BehaviorSubject<String> currentTab =
      BehaviorSubject<String>.seeded('HISTORY');
  List<TransactionView>? currentTxsCache;

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
    final Asset? securityAsset = security.asset;
    return securityAsset == null || securityAsset.hasMetadata == false;
  }

  Security get security =>
      (data['holding'] as Balance?)?.security ?? pros.securities.currentCoin;
  List<Balance> get currentHolds => Current.holdings;

  //List<TransactionRecord> get currentTxs {
  //  if (Current.wallet.minerMode) {
  //    return <TransactionRecord>[];
  //  }
  //  currentTxsCache ??= services.transaction.getTransactionRecords(
  //      wallet: Current.wallet, securities: <Security>{security});
  //  return currentTxsCache!;
  //}

  List<TransactionView> get currentTxs {
    if (Current.wallet.minerMode) {
      return <TransactionView>[];
    }
    currentTxsCache ??= services.transaction.getTransactionViewSpoof(
        wallet: Current.wallet, securities: <Security>{security});
    return currentTxsCache!;
  }

  void clearCache() => currentTxsCache = null;
}
