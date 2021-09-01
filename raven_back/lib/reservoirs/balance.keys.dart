part of 'balance.dart';

// primary key

String _accountSecurityToKey(String accountId, Security security) {
  return '$accountId:${security.toKey()}';
}

class _AccountSecurityKey extends Key<Balance> {
  @override
  String getKey(Balance balance) =>
      _accountSecurityToKey(balance.accountId, balance.security);
}

extension ByAccountSecurityMethodsForBalance
    on Index<_AccountSecurityKey, Balance> {
  Balance? getOne(String accountId, Security security) =>
      getByKeyStr(_accountSecurityToKey(accountId, security)).firstOrNull;
}

// byAccount

class _AccountKey extends Key<Balance> {
  @override
  String getKey(Balance balance) => balance.accountId;
}

extension ByAccountMethodsForBalance on Index<_AccountKey, Balance> {
  List<Balance> getAll(String accountId) => getByKeyStr(accountId);
}
