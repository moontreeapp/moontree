import 'package:raven_back/records/records.dart';

Map<String, Security> get securities => {
      'RVN:Crypto': Security(symbol: 'RVN', securityType: SecurityType.Crypto),
      'USD:Fiat': Security(symbol: 'USD', securityType: SecurityType.Fiat),
      'MOONTREE:RavenAsset':
          Security(symbol: 'MOONTREE', securityType: SecurityType.RavenAsset),
    };
