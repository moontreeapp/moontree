part of 'vout.dart';

// primary key

class _VoutKey extends Key<Vout> {
  @override
  String getKey(Vout vout) => vout.voutId;
}

extension ByIdMethodsForVout on Index<_VoutKey, Vout> {
  Vout? getOne(String hash) => getByKeyStr(hash).firstOrNull;
}

// byTransaction

class _TransactionKey extends Key<Vout> {
  @override
  String getKey(Vout vout) => vout.txId;
}

extension ByTransactionMethodsForVout on Index<_TransactionKey, Vout> {
  List<Vout> getAll(String txId) => getByKeyStr(txId);
}

// bySecurity

class _SecurityKey extends Key<Vout> {
  @override
  String getKey(Vout vout) => vout.securityId;
}

extension BySecurityMethodsForVout on Index<_SecurityKey, Vout> {
  List<Vout> getAll(Security security) => getByKeyStr(security.securityId);

  Iterable<Vout> unspents({Security security = RVN}) =>
      VoutReservoir.whereUnspent(given: getAll(security), security: security);

  BalanceRaw balance({Security security = RVN}) {
    var zero = BalanceRaw(confirmed: 0, unconfirmed: 0);
    return unspents(security: security).fold(
        zero,
        (sum, vout) =>
            sum +
            BalanceRaw(
                confirmed: (vout.confirmed ? vout.value : 0),
                unconfirmed: (!vout.confirmed ? vout.value : 0)));
  }
}
