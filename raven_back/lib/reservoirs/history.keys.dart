part of 'history.dart';

// primary key

class _TxHashKey extends Key<History> {
  @override
  String getKey(History history) => history.txHash;
}

// byAccount

class _AccountKey extends Key<History> {
  @override
  String getKey(History history) => history.accountId;
}

extension ByAccountMethodsForHistory on Index<_AccountKey, History> {
  List<History> getAll(String accountId) => getByKeyStr(accountId);
}

// byWallet

class _WalletKey extends Key<History> {
  @override
  String getKey(History history) => history.walletId;
}

extension ByWalletMethodsForHistory on Index<_WalletKey, History> {
  List<History> getAll(String walletId) => getByKeyStr(walletId);
}

// byScripthash

class _ScripthashKey extends Key<History> {
  @override
  String getKey(History history) => history.scripthash;
}

extension ByScripthashMethodsForHistory on Index<_ScripthashKey, History> {
  List<History> getAll(String scripthash) => getByKeyStr(scripthash);
}

// bySecurity

class _SecurityKey extends Key<History> {
  @override
  String getKey(History history) => history.security.toKey();
}

extension BySecurityMethodsForHistory on Index<_SecurityKey, History> {
  List<History> getAll(Security security) => getByKeyStr(security.toKey());
}
