import 'package:raven_back/raven_back.dart';

class WalletStreams {
  final leaderChanges = leaderChanges$;
  final singleChanges = singleChanges$;
}

final Stream<Change<Wallet>> leaderChanges$ =
    res.wallets.changes.where((change) => change.data is LeaderWallet);

final Stream<Change<Wallet>> singleChanges$ =
    res.wallets.changes.where((change) => change.data is SingleWallet);
