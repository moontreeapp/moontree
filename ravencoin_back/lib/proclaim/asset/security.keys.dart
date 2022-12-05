part of 'security.dart';

// primary key

class _IdKey extends Key<Security> {
  @override
  String getKey(Security security) => security.id;
}

extension ByIdMethodsForSecurity on Index<_IdKey, Security> {
  Security? getOneRaw(String? securityId) =>
      securityId == null ? null : getByKeyStr(securityId).firstOrNull;
  Security? getOne(String? symbol, Chain? chain, Net? net) =>
      [symbol, chain, net].contains(null)
          ? null
          : getByKeyStr(Security.key(symbol!, chain!, net!)).firstOrNull;
}

// bySymbol

class _SymbolKey extends Key<Security> {
  @override
  String getKey(Security security) => security.symbol;
}

extension BySymbolMethodsForSecurity on Index<_SymbolKey, Security> {
  List<Security> getAll(String symbol) => getByKeyStr(symbol);
}
