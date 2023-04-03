import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:client_back/client_back.dart';

part 'security.keys.dart';

class SecurityProclaim extends Proclaim<_IdKey, Security> {
  late IndexMultiple<_SymbolKey, Security> bySymbol;
  static Security staticUSD =
      const Security(symbol: 'USD', chain: Chain.none, net: Net.main);
  static Security staticRVN =
      const Security(symbol: 'RVN', chain: Chain.ravencoin, net: Net.main);
  static Security staticEVR =
      const Security(symbol: 'EVR', chain: Chain.evrmore, net: Net.main);
  static Security staticRVNt =
      const Security(symbol: 'RVN', chain: Chain.ravencoin, net: Net.test);
  static Security staticEVRt =
      const Security(symbol: 'EVR', chain: Chain.evrmore, net: Net.test);

  SecurityProclaim() : super(_IdKey()) {
    bySymbol = addIndexMultiple('symbol', _SymbolKey());
  }

  IndexUnique<_IdKey, Security> get byKey =>
      indices[constPrimaryIndex]! as IndexUnique<_IdKey, Security>;

  static Map<String, Security> get defaults => <String, Security>{
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

  final List<Security> coins = <Security>[
    SecurityProclaim.staticEVR,
    SecurityProclaim.staticRVN,
    SecurityProclaim.staticEVRt,
    SecurityProclaim.staticRVNt,
    SecurityProclaim.staticUSD,
  ];

  Set<String>? _coinSymbols;
  Set<String> get coinSymbols =>
      _coinSymbols ??= coins.map((Security e) => e.symbol).toSet();

  Security get currentCoin => coinOf(pros.settings.chain, pros.settings.net);

  Security coinOf(Chain chain, Net net) {
    if (chain == Chain.ravencoin && net == Net.main) {
      return RVN;
    } else if (chain == Chain.ravencoin && net == Net.test) {
      return RVNt;
    } else if (chain == Chain.evrmore && net == Net.main) {
      return EVR;
    } else if (chain == Chain.evrmore && net == Net.test) {
      return EVRt;
    } else {
      return USD;
    }
  }

  Security? ofCurrent(String symbol) =>
      primaryIndex.getOne(symbol, pros.settings.chain, pros.settings.net);
}
