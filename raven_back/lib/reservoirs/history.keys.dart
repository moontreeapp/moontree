part of 'history.dart';

// primary key

class _TxHashKey extends Key<History> {
  @override
  String getKey(History history) => history.hash;
}

extension ByIdMethodsForHistory on Index<_TxHashKey, History> {
  History? getOne(String hash) {
    var histories = getByKeyStr(hash);
    return histories.isEmpty ? null : histories.first;
  }
}

// byAccount

class _AccountKey extends Key<History> {
  @override
  String getKey(History history) => history.accountId;
}

extension ByAccountMethodsForHistory on Index<_AccountKey, History> {
  List<History> getAll(String accountId) => getByKeyStr(accountId);

  Iterable<History> transactions(String accountId, {Security security = RVN}) =>
      whereTransactions(getAll(accountId), security);

  Iterable<History> unspents(String accountId, {Security security = RVN}) =>
      whereUnspents(getAll(accountId), security);

  Iterable<History> unconfirmed(String accountId, {Security security = RVN}) =>
      whereUnconfirmed(getAll(accountId), security);
}

// byWallet

class _WalletKey extends Key<History> {
  @override
  String getKey(History history) => history.walletId;
}

extension ByWalletMethodsForHistory on Index<_WalletKey, History> {
  List<History> getAll(String walletId) => getByKeyStr(walletId);

  Iterable<History> transactions(String walletId, {Security security = RVN}) =>
      whereTransactions(getAll(walletId), security);

  Iterable<History> unspents(String walletId, {Security security = RVN}) =>
      whereUnspents(getAll(walletId), security);

  Iterable<History> unconfirmed(String walletId, {Security security = RVN}) =>
      whereUnconfirmed(getAll(walletId), security);
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

  Iterable<History> unspents({Security security = RVN}) =>
      whereUnspents(getAll(security), security);
}

// byConfirmed

class _ConfirmedKey extends Key<History> {
  @override
  String getKey(History history) => history.confirmed.toString();
}

extension ByConfrimedMethodsForHistory on Index<_ConfirmedKey, History> {
  List<History> getAll(bool confirmed) => getByKeyStr(confirmed.toString());
}

// FILTERS

Iterable<History> whereTransactions(
        Iterable<History> histories, Security security) =>
    histories.where((history) =>
        history.confirmed && // not in mempool
        history.security == security);

Iterable<History> whereUnspents(
        Iterable<History> histories, Security security) =>
    histories.where((history) =>
        history.value > 0 && // unspent
        history.confirmed && // not in mempool
        history.security == security);

Iterable<History> whereUnconfirmed(
        Iterable<History> histories, Security security) =>
    histories.where((history) =>
        history.value > 0 && // unspent
        !history.confirmed && // in mempool
        history.security == security);
