import 'package:raven_back/raven_back.dart';
import 'package:reservoir/map_source.dart';
import 'package:raven_back/globals.dart' as globals;
import 'package:raven_back/utils/database.dart' as raven_database;

void useFixtureSources() {
  globals.assets.setSource(MapSource({}));
  globals.rates.setSource(MapSource({}));
  globals.securities.setSource(MapSource({
    'RVN:Crypto': Security(symbol: 'RVN', securityType: SecurityType.Crypto),
    'USD:Fiat': Security(symbol: 'USD', securityType: SecurityType.Fiat),
  }));
}

void deleteDatabase() => raven_database.deleteDatabase();
