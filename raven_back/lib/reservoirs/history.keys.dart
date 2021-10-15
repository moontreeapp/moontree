part of 'history.dart';

// primary key

class _TxHashKey extends Key<History> {
  @override
  String getKey(History history) => history.txId;
}

extension ByIdMethodsForHistory on Index<_TxHashKey, History> {
  History? getOne(String hash) => getByKeyStr(hash).firstOrNull;
}

// byAddress

class _AddressKey extends Key<History> {
  @override
  String getKey(History history) => history.address?.address ?? '';
}

extension ByAddressMethodsForHistory on Index<_AddressKey, History> {
  List<History> getAll(String address) => getByKeyStr(address);
}

// byScripthash

class _ScripthashKey extends Key<History> {
  @override
  String getKey(History history) => history.addressId;
}

extension ByScripthashMethodsForHistory on Index<_ScripthashKey, History> {
  List<History> getAll(String addressId) => getByKeyStr(addressId);
}

// bySecurity

class _SecurityKey extends Key<History> {
  @override
  String getKey(History history) => history.security.toKey();
}

extension BySecurityMethodsForHistory on Index<_SecurityKey, History> {
  List<History> getAll(Security security) => getByKeyStr(security.toKey());

  Iterable<History> unspents({Security security = RVN}) =>
      HistoryReservoir.whereUnspent(
          given: getAll(security), security: security);

  BalanceRaw balance({Security security = RVN}) {
    var zero = BalanceRaw(confirmed: 0, unconfirmed: 0);
    return unspents(security: security).fold(
        zero,
        (sum, history) =>
            sum +
            BalanceRaw(
                confirmed: (history.confirmed ? history.value : 0),
                unconfirmed: (!history.confirmed ? history.value : 0)));
  }
}

// byConfirmed

class _ConfirmedKey extends Key<History> {
  @override
  String getKey(History history) => history.confirmed.toString();
}

extension ByConfrimedMethodsForHistory on Index<_ConfirmedKey, History> {
  List<History> getAll(bool confirmed) => getByKeyStr(confirmed.toString());
}
