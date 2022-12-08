import 'package:equatable/equatable.dart';

import 'package:ravencoin_back/ravencoin_back.dart';

class WalletSecurityPair with EquatableMixin {
  WalletSecurityPair({required this.wallet, required this.security});

  final Wallet wallet;
  final Security security;

  @override
  List<Object?> get props => <Object?>[wallet, security];
}

Set<WalletSecurityPair> securityPairsFromVoutChanges(
    List<Change<Vout>> changes) {
  return changes.fold(<WalletSecurityPair>{},
      (Set<WalletSecurityPair> set, Change<Vout> change) {
    final Vout vout = change.record;
    if (vout.wallet != null) {
      return set
        ..add(WalletSecurityPair(
            wallet: vout.wallet!,
            security: vout.security ?? pros.securities.currentCoin));
    }
    return set;
  });
}

Set<WalletSecurityPair> securityPairsFromVouts(List<Vout> vouts) {
  return <WalletSecurityPair>{
    for (Vout vout in vouts)
      if (vout.wallet != null)
        WalletSecurityPair(
            wallet: vout.wallet!,
            security: vout.security ?? pros.securities.currentCoin)
  };
}
