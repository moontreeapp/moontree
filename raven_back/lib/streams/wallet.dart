import 'package:raven_back/raven_back.dart';
import 'package:rxdart/rxdart.dart';

class WalletStreams {
  final replay = replayWallet$;
  final leaderChanges = leaderChanges$;
  final singleChanges = singleChanges$;
  final deriveAddress = BehaviorSubject<DeriveLeaderAddress?>.seeded(null);
  final transactions =
      BehaviorSubject<WalletExposureTransactions?>.seeded(null);
}

final Stream<Wallet> replayWallet$ = ReplaySubject<Wallet>()
  ..addStream(res.wallets.changes
      .where((change) => change is Loaded || change is Added)
      .map((added) => added.data));

final Stream<Change<Wallet>> leaderChanges$ =
    res.wallets.changes.where((change) => change.data is LeaderWallet);

final Stream<Change<Wallet>> singleChanges$ =
    res.wallets.changes.where((change) => change.data is SingleWallet);

class DeriveLeaderAddress {
  final LeaderWallet leader;
  final NodeExposure? exposure;

  DeriveLeaderAddress({required this.leader, this.exposure});
}

class WalletExposureTransactions {
  final String walletId;
  final NodeExposure exposure;
  final Iterable<String> transactionIds;
  final Wallet? wallet;

  WalletExposureTransactions({
    required this.walletId,
    required this.exposure,
    required this.transactionIds,
    this.wallet,
  });

  String get key => walletId + exposure.enumString;
}
