import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/map_source.dart';
import 'package:ravencoin_back/utilities/database.dart' as raven_database;

void useFixtureSources() {
  pros.assets.setSource(MapSource({}));
  pros.rates.setSource(MapSource({}));
  pros.securities.setSource(MapSource({
    'RVN:Crypto':
        Security(symbol: 'RVN', chain: Chain.ravencoin, net: Net.test),
    'USD:Fiat': Security(symbol: 'USD', chain: Chain.none, net: Net.test),
  }));
}

void deleteDatabase() => raven_database.deleteDatabase();
