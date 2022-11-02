part of 'security.dart';

// primary key

class _IdKey extends Key<Security> {
  @override
  String getKey(Security security) => security.id;
}

extension ByIdMethodsForSecurity on Index<_IdKey, Security> {
  Security? getOneRaw(String? securityId) =>
      securityId == null ? null : getByKeyStr(securityId).firstOrNull;
  Security? getOne(
          String? symbol, SecurityType? securityType, Chain? chain, Net? net) =>
      [symbol, securityType, chain, net].contains(null)
          ? null
          : getByKeyStr(Security.key(symbol!, securityType!, chain!, net!))
              .firstOrNull;
}

// bySymbol

class _SymbolKey extends Key<Security> {
  @override
  String getKey(Security security) => security.symbol;
}

extension BySymbolMethodsForSecurity on Index<_SymbolKey, Security> {
  List<Security> getAll(String symbol) => getByKeyStr(symbol);
}

// bySymbolChainNet

class _SymbolChainNetKey extends Key<Security> {
  @override
  String getKey(Security security) => security.symbolChainNet;
}

extension BySymbolChainNetMethodsForSecurity
    on Index<_SymbolChainNetKey, Security> {
  List<Security> getAll(String symbol, Chain chain, Net net) =>
      getByKeyStr(Security.symbolChainNetKey(symbol, chain, net));
}

// bySecurityType

class _SecurityTypeKey extends Key<Security> {
  @override
  String getKey(Security security) => security.securityTypeName;
}

extension BySecurityTypeMethodsForSecurity
    on Index<_SecurityTypeKey, Security> {
  List<Security> getAll(SecurityType securityType) =>
      getByKeyStr(securityType.toString());
}
