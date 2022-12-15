import 'sets.dart';
import 'package:ravencoin_back/proclaim/proclaim.dart';
import 'package:proclaim/map_source.dart';
import 'package:ravencoin_back/utilities/database.dart' as raven_database;

export 'sets.dart';

/// meant to be used for loading only what the test/group needs. preferred to
/// useFixtureSources because this requires that the app state (contents of the
/// proclaim) be immediately present near the test and therefore obvious.
void useEmptyFixtures({bool defaults = true}) {
  pros.addresses.setSource(MapSource({}));
  pros.assets.setSource(MapSource({}));
  pros.balances.setSource(MapSource({}));
  pros.blocks.setSource(MapSource({}));
  pros.ciphers.setSource(MapSource(defaults ? CipherProclaim.defaults : {}));
  pros.metadatas.setSource(MapSource({}));
  pros.passwords.setSource(MapSource({}));
  pros.rates.setSource(MapSource({}));
  pros.transactions.setSource(MapSource({}));
  pros.securities
      .setSource(MapSource(defaults ? SecurityProclaim.defaults : {}));
  pros.settings.setSource(MapSource(defaults ? SettingProclaim.defaults : {}));
  pros.vins.setSource(MapSource({}));
  pros.vouts.setSource(MapSource({}));
  pros.wallets.setSource(MapSource({}));
}

/// meant to be used for any number of complex groupings of app state
void useFixtureSources(int? version) {
  FixtureSet set = {
        0: FixtureSet0(),
        1: FixtureSet1(),
      }[version] ??
      FixtureSet0();
  pros.addresses.setSource(MapSource(set.addresses));
  pros.assets.setSource(MapSource(set.assets));
  pros.balances.setSource(MapSource(set.balances));
  pros.blocks.setSource(MapSource(set.blocks));
  pros.ciphers.setSource(MapSource(set.ciphers));
  pros.metadatas.setSource(MapSource(set.metadatas));
  pros.passwords.setSource(MapSource(set.passwords));
  pros.rates.setSource(MapSource(set.rates));
  pros.transactions.setSource(MapSource(set.transactions));
  pros.securities.setSource(MapSource(set.securities));
  pros.settings.setSource(MapSource(set.settings));
  pros.vins.setSource(MapSource(set.vins));
  pros.vouts.setSource(MapSource(set.vouts));
  pros.wallets.setSource(MapSource(set.wallets));
}

void useFixtureSources1() => useFixtureSources(1);
void deleteDatabase() => raven_database.deleteDatabase();
