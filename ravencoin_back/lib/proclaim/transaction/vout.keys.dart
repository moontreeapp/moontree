part of 'vout.dart';

// primary key

class _IdKey extends Key<Vout> {
  @override
  String getKey(Vout vout) => vout.id;
}

extension ByIdMethodsForVout on Index<_IdKey, Vout> {
  Vout? getOne(String hash) => getByKeyStr(hash).firstOrNull;
  Vout? getOneByTransactionPosition(String transactionId, int position) =>
      getByKeyStr(Vout.getVoutId(transactionId, position)).firstOrNull;
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
}

// bySecurityType

class _SecurityTypeKey extends Key<Vout> {
  @override
  String getKey(Vout vout) => vout.securityId.split(':').last;
}

extension BySecurityTypeMethodsForVout on Index<_SecurityTypeKey, Vout> {
  List<Vout> getAll(SecurityType securityType) =>
      getByKeyStr(securityType.name);
}

// byAddress - not every vout has an address

class _AddressKey extends Key<Vout> {
  @override
  String getKey(Vout vout) => vout.toAddress ?? '';
}

extension ByAddressMethodsForVout on Index<_AddressKey, Vout> {
  List<Vout> getAll(String address) => getByKeyStr(address);
}
