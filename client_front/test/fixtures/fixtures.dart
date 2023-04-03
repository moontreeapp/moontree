import 'package:proclaim/map_source.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/utilities/database.dart' as raven_database;

void useFixtureSources() {
  pros.assets.setSource(MapSource<Asset>(<String, Asset>{}));
  pros.rates.setSource(MapSource<Rate>(<String, Rate>{}));
  pros.securities.setSource(MapSource<Security>(<String, Security>{
    'RVN:Crypto':
        const Security(symbol: 'RVN', chain: Chain.ravencoin, net: Net.test),
    'USD:Fiat': const Security(symbol: 'USD', chain: Chain.none, net: Net.test),
  }));
}

void deleteDatabase() => raven_database.deleteDatabase();
