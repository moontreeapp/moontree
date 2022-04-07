import 'package:raven_back/raven_back.dart';
import 'package:reservoir/map_source.dart';
import 'package:raven_back/utilities/database.dart' as raven_database;

void useFixtureSources() {
  res.assets.setSource(MapSource({}));
  res.rates.setSource(MapSource({}));
  res.securities.setSource(MapSource({
    'RVN:Crypto': Security(symbol: 'RVN', securityType: SecurityType.Crypto),
    'USD:Fiat': Security(symbol: 'USD', securityType: SecurityType.Fiat),
  }));
}

void deleteDatabase() => raven_database.deleteDatabase();
