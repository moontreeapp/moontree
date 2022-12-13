import 'package:rxdart/rxdart.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show ReadableIdentifierExtension;

class WalletStreams {
  final Stream<Wallet> replay = ReplaySubject<Wallet>()
    ..addStream(pros.wallets.changes
        .where((Change<Wallet> change) => change is Loaded || change is Added)
        .map((Change<Wallet> added) => added.record))
    ..name = 'wallet.replay';
  final Stream<Change<Wallet>> leaderChanges = pros.wallets.changes
      .where((Change<Wallet> change) => change.record is LeaderWallet)
    ..name = 'wallet.leaderChanges';
  final Stream<Change<Wallet>> singleChanges = pros.wallets.changes
      .where((Change<Wallet> change) => change.record is SingleWallet)
    ..name = 'wallet.singleChanges';
  final BehaviorSubject<DeriveLeaderAddress?> deriveAddress =
      BehaviorSubject<DeriveLeaderAddress?>.seeded(null)
        ..name = 'wallet.deriveAddress';
  final BehaviorSubject<WalletExposureTransactions?> transactions =
      BehaviorSubject<WalletExposureTransactions?>.seeded(null)
        ..name = 'wallet.transactions';
}

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
