export 'sets.dart';

import 'package:raven_back/reservoirs/cipher.dart';
import 'package:raven_back/reservoirs/security.dart';
import 'package:raven_back/reservoirs/setting.dart';

import 'sets.dart';

import 'package:reservoir/map_source.dart';
import 'package:raven_back/globals.dart' as globals;
import 'package:raven_back/utils/database.dart' as raven_database;

/// meant to be used for loading only what the test/group needs. preferred to
/// useFixtureSources because this requires that the app state (contents of the
/// reservoirs) be immediately present near the test and therefore obvious.
void useEmptyFixtures({bool defaults = true}) {
  globals.res.accounts.setSource(MapSource({}));
  globals.res.addresses.setSource(MapSource({}));
  globals.res.assets.setSource(MapSource({}));
  globals.res.balances.setSource(MapSource({}));
  globals.res.blocks.setSource(MapSource({}));
  globals.res.ciphers
      .setSource(MapSource(defaults ? CipherReservoir.defaults : {}));
  globals.res.metadatas.setSource(MapSource({}));
  globals.res.passwords.setSource(MapSource({}));
  globals.res.rates.setSource(MapSource({}));
  globals.res.transactions.setSource(MapSource({}));
  globals.res.securities
      .setSource(MapSource(defaults ? SecurityReservoir.defaults : {}));
  globals.res.settings
      .setSource(MapSource(defaults ? SettingReservoir.defaults : {}));
  globals.res.vins.setSource(MapSource({}));
  globals.res.vouts.setSource(MapSource({}));
  globals.res.wallets.setSource(MapSource({}));
}

/// meant to be used for any number of complex groupings of app state
void useFixtureSources(int? version) {
  var set;
  if (version == 0) {
    set = FixtureSet0;
  } else if (version == 1) {
    set = FixtureSet1;
  } else {
    set = FixtureSet0;
  }
  globals.res.accounts.setSource(MapSource(set.accounts));
  globals.res.addresses.setSource(MapSource(set.addresses));
  globals.res.assets.setSource(MapSource(set.assets));
  globals.res.balances.setSource(MapSource(set.balances));
  globals.res.blocks.setSource(MapSource(set.blocks));
  globals.res.ciphers.setSource(MapSource(set.ciphers));
  globals.res.metadatas.setSource(MapSource(set.metadatas));
  globals.res.passwords.setSource(MapSource(set.passwords));
  globals.res.rates.setSource(MapSource(set.rates));
  globals.res.transactions.setSource(MapSource(set.transactions));
  globals.res.securities.setSource(MapSource(set.securities));
  globals.res.settings.setSource(MapSource(set.settings));
  globals.res.vins.setSource(MapSource(set.vins));
  globals.res.vouts.setSource(MapSource(set.vouts));
  globals.res.wallets.setSource(MapSource(set.wallets));
}

void useFixtureSources1() => useFixtureSources(1);

void deleteDatabase() => raven_database.deleteDatabase();
