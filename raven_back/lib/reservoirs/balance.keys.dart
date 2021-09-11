part of 'balance.dart';

// primary key

String _walletSecurityToKey(String walletId, Security security) {
  return '$walletId:${security.toKey()}';
}

class _WalletSecurityKey extends Key<Balance> {
  @override
  String getKey(Balance balance) =>
      _walletSecurityToKey(balance.walletId, balance.security);
}

extension ByWalletSecurityMethodsForBalance
    on Index<_WalletSecurityKey, Balance> {
  Balance? getOne(String walletId, Security security) =>
      getByKeyStr(_walletSecurityToKey(walletId, security)).firstOrNull;
}

// byWallet

class _WalletKey extends Key<Balance> {
  @override
  String getKey(Balance balance) => balance.walletId;
}

extension ByWalletMethodsForBalance on Index<_WalletKey, Balance> {
  List<Balance> getAll(String walletId) => getByKeyStr(walletId);
}

// byAccount

//class _AccountKey extends Key<Balance> {
//  @override
//  String getKey(Balance balance) => balance.wallet!.accountId;
//}
//
//extension ByAccountMethodsForBalance on Index<_AccountKey, Balance> {
//  List<Balance> getAll(String accountId) => getByKeyStr(accountId);
//}
