import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'security.keys.dart';

class SecurityProclaim extends Proclaim<_SecurityIdKey, Security> {
  late IndexMultiple<_SymbolKey, Security> bySymbol;
  late IndexMultiple<_SecurityTypeKey, Security> bySecurityType;
  late IndexMultiple<_SymbolSecurityTypeKey, Security> bySymbolSecurityType;

  SecurityProclaim() : super(_SecurityIdKey()) {
    bySymbol = addIndexMultiple('symbol', _SymbolKey());
    bySecurityType = addIndexMultiple('securityType', _SecurityTypeKey());
    bySymbolSecurityType =
        addIndexMultiple('symbolSecurityType', _SymbolSecurityTypeKey());
  }

  static Map<String, Security> get defaults => {
        'USD:Fiat': Security(symbol: 'USD', securityType: SecurityType.Fiat),
        'RVN:Crypto': Security(symbol: 'RVN', securityType: SecurityType.Crypto)
      };

  Security get RVN =>
      primaryIndex.getOne('RVN:Crypto') ??
      SecurityProclaim.defaults['RVN:Crypto']!;
  Security get USD =>
      primaryIndex.getOne('USD:Fiat') ?? SecurityProclaim.defaults['USD:Fiat']!;
}
