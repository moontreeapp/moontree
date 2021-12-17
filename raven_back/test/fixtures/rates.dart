import 'package:raven_back/records/records.dart';

Map<String, Rate> get rates => {
      'RVN:Crypto:USD:Fiat': Rate(
          base: Security(symbol: 'RVN', securityType: SecurityType.Crypto),
          quote: Security(symbol: 'USD', securityType: SecurityType.Fiat),
          rate: .1),
      'MOONTREE:RavenAsset:RVN:Crypto': Rate(
          base: Security(
              symbol: 'MOONTREE', securityType: SecurityType.RavenAsset),
          quote: Security(symbol: 'RVN', securityType: SecurityType.Crypto),
          rate: 100),
    };
