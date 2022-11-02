import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'security.keys.dart';

class SecurityProclaim extends Proclaim<_IdKey, Security> {
  late IndexMultiple<_SymbolKey, Security> bySymbol;
  late IndexMultiple<_SecurityTypeKey, Security> bySecurityType;
  static final staticUSD = Security(
      symbol: 'USD',
      securityType: SecurityType.fiat,
      chain: Chain.none,
      net: Net.main);
  static final staticRVN = Security(
      symbol: 'RVN',
      securityType: SecurityType.crypto,
      chain: Chain.ravencoin,
      net: Net.main);
  static final staticEVR = Security(
      symbol: 'EVR',
      securityType: SecurityType.crypto,
      chain: Chain.evrmore,
      net: Net.main);
  static final staticRVNt = Security(
      symbol: 'RVN',
      securityType: SecurityType.crypto,
      chain: Chain.ravencoin,
      net: Net.test);
  static final staticEVRt = Security(
      symbol: 'EVR',
      securityType: SecurityType.crypto,
      chain: Chain.evrmore,
      net: Net.test);

  SecurityProclaim() : super(_IdKey()) {
    bySymbol = addIndexMultiple('symbol', _SymbolKey());
    bySecurityType = addIndexMultiple('securityType', _SecurityTypeKey());
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

  final List<Security> cryptos = [
    SecurityProclaim.staticUSD,
    SecurityProclaim.staticRVN,
    SecurityProclaim.staticEVR,
    SecurityProclaim.staticRVNt,
    SecurityProclaim.staticEVRt,
  ];
}
