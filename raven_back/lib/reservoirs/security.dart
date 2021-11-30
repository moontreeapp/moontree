import 'package:collection/collection.dart';
import 'package:raven_back/raven_back.dart';
import 'package:reservoir/reservoir.dart';

part 'security.keys.dart';

class SecurityReservoir extends Reservoir<_SecurityIdKey, Security> {
  late IndexMultiple<_SymbolKey, Security> bySymbol;
  late IndexMultiple<_SecurityTypeKey, Security> bySecurityType;
  late IndexMultiple<_SymbolSecurityTypeKey, Security> bySymbolSecurityType;

  SecurityReservoir() : super(_SecurityIdKey()) {
    bySymbol = addIndexMultiple('symbol', _SymbolKey());
    bySecurityType = addIndexMultiple('securityType', _SecurityTypeKey());
    bySymbolSecurityType =
        addIndexMultiple('symbolSecurityType', _SymbolSecurityTypeKey());
  }

  static Map<String, Security> get defaults => {
        'USD:Fiat': Security(symbol: 'USD', securityType: SecurityType.Fiat),
        'RVN:Crypto': Security(symbol: 'RVN', securityType: SecurityType.Crypto)
      };

  Security get RVN => primaryIndex.getOne('RVN:Crypto')!;
  Security get USD => primaryIndex.getOne('USD:Fiat')!;
}
