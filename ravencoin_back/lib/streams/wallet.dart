import 'package:rxdart/rxdart.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class WalletStreams {
  final Stream<Wallet> replay = replayWallet$;
  final Stream<Change<Wallet>> leaderChanges = leaderChanges$;
  final Stream<Change<Wallet>> singleChanges = singleChanges$;
  final BehaviorSubject<DeriveLeaderAddress?> deriveAddress =
      BehaviorSubject<DeriveLeaderAddress?>.seeded(null);
  final BehaviorSubject<WalletExposureTransactions?> transactions =
      BehaviorSubject<WalletExposureTransactions?>.seeded(null);
}

final Stream<Wallet> replayWallet$ = ReplaySubject<Wallet>()
  ..addStream(pros.wallets.changes
      .where((Change<Wallet> change) => change is Loaded || change is Added)
      .map((Change<Wallet> added) => added.record));

final Stream<Change<Wallet>> leaderChanges$ = pros.wallets.changes
    .where((Change<Wallet> change) => change.record is LeaderWallet);

final Stream<Change<Wallet>> singleChanges$ = pros.wallets.changes
    .where((Change<Wallet> change) => change.record is SingleWallet);

class DeriveLeaderAddress {
  DeriveLeaderAddress({
    required this.leader,
    this.exposure,
  });
  final LeaderWallet leader;
  final NodeExposure? exposure;
}

class WalletExposureTransactions {
  WalletExposureTransactions({
    required this.address,
    required this.transactionIds,
  });
  final Address address;
  final Iterable<String> transactionIds;

  String get key => produceKey(address.walletId, address.exposure);
  static String produceKey(String walletId, NodeExposure exposure) =>
      walletId + exposure.name;
}
