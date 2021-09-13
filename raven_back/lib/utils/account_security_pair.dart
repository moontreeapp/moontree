import 'package:equatable/equatable.dart';
import 'package:reservoir/change.dart';

import 'package:raven/raven.dart';

class WalletSecurityPair with EquatableMixin {
  final Wallet wallet;
  final Security security;

  WalletSecurityPair(this.wallet, this.security);

  factory WalletSecurityPair.fromChange(Change change) {
    History history = change.data;
    return WalletSecurityPair(history.address!.wallet!, change.data.security);
  }
  @override
  List<Object?> get props => [wallet, security];
}

Set<WalletSecurityPair> uniquePairsFromHistoryChanges(List<Change> changes) {
  return changes.fold({}, (set, change) {
    set.add(WalletSecurityPair.fromChange(change));
    return set;
  });
}
