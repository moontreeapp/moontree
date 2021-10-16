import 'package:collection/collection.dart';
import 'package:raven/raven.dart';
import 'package:reservoir/reservoir.dart';

part 'security.keys.dart';

class SecurityReservoir extends Reservoir<_SecurityIdKey, Security> {
  late IndexMultiple<_SymbolKey, Security> bySymbol;
  late IndexMultiple<_SecurityTypeKey, Security> bySecurityType;

  SecurityReservoir() : super(_SecurityIdKey()) {
    bySymbol = addIndexMultiple('symbol', _SymbolKey());
    bySecurityType = addIndexMultiple('securityType', _SecurityTypeKey());
  }
}
