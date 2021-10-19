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
    return set
      ..add(WalletSecurityPair(
          vout.wallet!, securities.primaryIndex.getOne(vout.securityId)!));
  });
}
