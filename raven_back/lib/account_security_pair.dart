import 'package:equatable/equatable.dart';
import 'package:reservoir/change.dart';

import 'package:raven/records.dart';

class AccountSecurityPair with EquatableMixin {
  final String accountId;
  final Security security;

  AccountSecurityPair(this.accountId, this.security);

  factory AccountSecurityPair.fromChange(Change change) =>
      AccountSecurityPair(change.data.accountId, change.data.security);

  @override
  List<Object?> get props => [accountId, security];
}

Set<AccountSecurityPair> uniquePairsFromHistoryChanges(List<Change> changes) {
  return changes.fold({}, (set, change) {
    set.add(AccountSecurityPair.fromChange(change));
    return set;
  });
}
