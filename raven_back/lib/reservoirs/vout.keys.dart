part of 'vout.dart';

// primary key

class _VoutKey extends Key<Vout> {
  @override
  String getKey(Vout vout) => vout.id;
}

extension ByIdMethodsForVout on Index<_VoutKey, Vout> {
  Vout? getOne(String hash) => getByKeyStr(hash).firstOrNull;
}

// byTransaction

class _TransactionKey extends Key<Vout> {
  @override
  String getKey(Vout vout) => vout.transactionId;
}

extension ByTransactionMethodsForVout on Index<_TransactionKey, Vout> {
  List<Vout> getAll(String transactionId) => getByKeyStr(transactionId);
}

// bySecurity

class _SecurityKey extends Key<Vout> {
  @override
  String getKey(Vout vout) => vout.assetSecurityId!;
}

extension BySecurityMethodsForVout on Index<_SecurityKey, Vout> {
  List<Vout> getAll(Security security) => getByKeyStr(security.id);

  /// delete this
  //Iterable<Vout> unspents({required Security security}) =>
  //    VoutReservoir.whereUnspent(given: getAll(security), security: security);
  //
  ///// ! todo this is probably broken because I don't think we can use joins
  ///// in here. Besides, I'm not even sure why this is here...
  //BalanceRaw balance({
  //  required Security security,
  //}) =>
  //    unspents(security: security).fold(
  //        BalanceRaw(confirmed: 0, unconfirmed: 0),
  //        (sum, vout) =>
  //            sum +
  //            BalanceRaw(
  //                confirmed: ((vout.transaction?.confirmed ?? true)
  //                    ? vout.rvnValue
  //                    : 0),
  //                unconfirmed: (!(vout.transaction?.confirmed ?? true)
  //                    ? vout.rvnValue
  //                    : 0)));
}

// byAddress - not every vout has an address

class _AddressKey extends Key<Vout> {
  @override
  String getKey(Vout vout) => vout.toAddress;
}

extension ByAddressMethodsForVout on Index<_AddressKey, Vout> {
  List<Vout> getAll(String address) => getByKeyStr(address);
}
