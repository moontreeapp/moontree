part of 'balance.dart';

// primary key

class _WalletSecurityKey extends Key<Balance> {
  @override
  String getKey(Balance balance) => balance.balanceId;
}

extension ByWalletSecurityMethodsForBalance
    on Index<_WalletSecurityKey, Balance> {
  Balance? getOne(String walletId, Security security) =>
      getByKeyStr(Balance.balanceKey(walletId, security)).firstOrNull;
}

// byWallet

class _WalletKey extends Key<Balance> {
  @override
  String getKey(Balance balance) => balance.walletId;
}

extension ByWalletMethodsForBalance on Index<_WalletKey, Balance> {
  List<Balance> getAll(String walletId) => getByKeyStr(walletId);
}

// bySecurity

class _SecurityKey extends Key<Balance> {
  @override
  String getKey(Balance balance) => balance.security.securityId;
}

extension BySecurityMethodsForBalance on Index<_SecurityKey, Balance> {
  List<Balance> getAll(Security security) => getByKeyStr(security.securityId);
}
