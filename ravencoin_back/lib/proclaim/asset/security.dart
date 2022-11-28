import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'security.keys.dart';

class SecurityProclaim extends Proclaim<_IdKey, Security> {
  late IndexMultiple<_SymbolKey, Security> bySymbol;
  static final staticUSD =
      Security(symbol: 'USD', chain: Chain.none, net: Net.main);
  static final staticRVN =
      Security(symbol: 'RVN', chain: Chain.ravencoin, net: Net.main);
  static final staticEVR =
      Security(symbol: 'EVR', chain: Chain.evrmore, net: Net.main);
  static final staticRVNt =
      Security(symbol: 'RVN', chain: Chain.ravencoin, net: Net.test);
  static final staticEVRt =
      Security(symbol: 'EVR', chain: Chain.evrmore, net: Net.test);

  SecurityProclaim() : super(_IdKey()) {
    bySymbol = addIndexMultiple('symbol', _SymbolKey());
  }

  IndexUnique<_IdKey, Security> get byKey =>
      indices[constPrimaryIndex]! as IndexUnique<_IdKey, Security>;

  static Map<String, Security> get defaults => {
        SecurityProclaim.staticUSD.id: SecurityProclaim.staticUSD,
        SecurityProclaim.staticRVN.id: SecurityProclaim.staticRVN,
        SecurityProclaim.staticEVR.id: SecurityProclaim.staticEVR,
        SecurityProclaim.staticRVNt.id: SecurityProclaim.staticRVNt,
        SecurityProclaim.staticEVRt.id: SecurityProclaim.staticEVRt,
      };

  final Security USD = SecurityProclaim.staticUSD;
  final Security RVN = SecurityProclaim.staticRVN;
  final Security EVR = SecurityProclaim.staticEVR;
  final Security RVNt = SecurityProclaim.staticRVNt;
  final Security EVRt = SecurityProclaim.staticEVRt;

  final List<Security> coins = [
    SecurityProclaim.staticUSD,
    SecurityProclaim.staticRVN,
    SecurityProclaim.staticEVR,
    SecurityProclaim.staticRVNt,
    SecurityProclaim.staticEVRt,
  ];

  Security get currentCoin {
    if (pros.settings.chain == Chain.ravencoin &&
        pros.settings.net == Net.main) {
      return RVN;
    } else if (pros.settings.chain == Chain.ravencoin &&
        pros.settings.net == Net.test) {
      return RVNt;
    } else if (pros.settings.chain == Chain.evrmore &&
        pros.settings.net == Net.main) {
      return EVR;
    } else if (pros.settings.chain == Chain.evrmore &&
        pros.settings.net == Net.test) {
      return EVRt;
    } else {
      return USD;
    }
  }

  SecurityType symbolSecurityType(String symbol) {
    if (symbol == 'USD') {
      return SecurityType.fiat;
    } else if (symbol == chainSymbol(pros.settings.chain)) {
      return SecurityType.coin;
    }
    return SecurityType.asset;
  }

  Security? ofCurrent(String symbol) =>
      primaryIndex.getOne(symbol, pros.settings.chain, pros.settings.net);
}
