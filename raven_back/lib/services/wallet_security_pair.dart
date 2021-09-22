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

Set<WalletSecurityPair> securityPairsFromHistoryChanges(List<Change> changes) {
  return changes.fold({}, (set, change) {
    History history = change.data;
    return set..add(WalletSecurityPair(history.wallet!, history.security));
  });
}
