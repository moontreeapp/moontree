import 'package:raven/raven.dart';

class WalletStreams {
  final leaderChanges = leaderChanges$;
  final singleChanges = singleChanges$;
}

final Stream<Change<Wallet>> leaderChanges$ = wallets.changes
    .where((change) => change.data is LeaderWallet)
    .map((event) => event);

final Stream<Change<Wallet>> singleChanges$ = wallets.changes
    .where((change) => change.data is SingleWallet)
    .map((event) => event);
