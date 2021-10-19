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
    // getting a null error on securities... why? shouldn't we have the security saved?
    print(vout.securityId);
    return set
      ..add(WalletSecurityPair(vout.transaction!.wallet!,
          securities.primaryIndex.getOne(vout.securityId)!));
  });
}
