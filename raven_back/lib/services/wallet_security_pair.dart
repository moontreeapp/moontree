import 'package:equatable/equatable.dart';

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
    if (vout.wallet != null) {
      return set
        ..add(WalletSecurityPair(
            vout.wallet!,
            securities.primaryIndex
                .getOne(vout.assetSecurityId ?? securities.RVN.securityId)!));
    }
    return set;
  });
}

Set<WalletSecurityPair> securityPairsFromVouts(List<Vout> vouts) {
  return {
    for (var vout in vouts)
      if (vout.wallet != null)
        WalletSecurityPair(
            vout.wallet!,
            securities.primaryIndex
                .getOne(vout.assetSecurityId ?? securities.RVN.securityId)!)
  };
}
