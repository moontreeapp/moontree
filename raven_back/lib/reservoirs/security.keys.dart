part of 'security.dart';

// primary key

class _SecurityIdKey extends Key<Security> {
  @override
  String getKey(Security security) => security.securityId;
}

extension ByIdMethodsForSecurity on Index<_SecurityIdKey, Security> {
  Security? getOne(String securityId) => getByKeyStr(securityId).firstOrNull;
}

// bySymbol

class _SymbolKey extends Key<Security> {
  @override
  String getKey(Security security) => security.symbol;
}

extension BySymbolMethodsForSecurity on Index<_SymbolKey, Security> {
  List<Security> getAll(String symbol) => getByKeyStr(symbol);
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
