import 'package:equatable/equatable.dart';
import 'package:reservoir/change.dart';

import 'package:raven/raven.dart';

class WalletSecurityPair with EquatableMixin {
  final Wallet wallet;
  final Security security;

  WalletSecurityPair(this.wallet, this.security);

  @override
  List<Object?> get props => [wallet, security];
}

Set<WalletSecurityPair> securityPairsFromVoutChanges(List<Change> changes) {
  return changes.fold({}, (set, change) {
    Vout vout = change.data;
    // fails - we're getting vouts for transactions we don't have?
    // I'm sure we're getting vins for vouts we don't have, but that's weird.
    print(vout);
    // 6157c77511af147fad4f90c304bf08cb996b701fa4449176dfa571cfbb96c538
    print(transactions);
    print(transactions.primaryIndex.getOne(
        '6157c77511af147fad4f90c304bf08cb996b701fa4449176dfa571cfbb96c538'));

    /// I believe this is happening because transactions are assigned to addresses,
    /// and truely vins and vouts should be assigned to addresses. because a transaction
    /// can have multiple of both and they can all be associated with different addresses...
    /// I think we might be loosing the transaction on purge
    return set
      ..add(WalletSecurityPair(vout.transaction!.wallet!,
          securities.primaryIndex.getOne(vout.securityId)!));
  });
}
