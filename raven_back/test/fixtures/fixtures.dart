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
  globals.accounts.setSource(MapSource({}));
  globals.addresses.setSource(MapSource({}));
  globals.assets.setSource(MapSource({}));
  globals.balances.setSource(MapSource({}));
  globals.blocks.setSource(MapSource({}));
  globals.ciphers
      .setSource(MapSource(defaults ? CipherReservoir.defaults : {}));
  globals.metadatas.setSource(MapSource({}));
  globals.passwords.setSource(MapSource({}));
  globals.rates.setSource(MapSource({}));
  globals.transactions.setSource(MapSource({}));
  globals.securities
      .setSource(MapSource(defaults ? SecurityReservoir.defaults : {}));
  globals.settings
      .setSource(MapSource(defaults ? SettingReservoir.defaults : {}));
  globals.vins.setSource(MapSource({}));
  globals.vouts.setSource(MapSource({}));
  globals.wallets.setSource(MapSource({}));
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
  globals.accounts.setSource(MapSource(set.accounts));
  globals.addresses.setSource(MapSource(set.addresses));
  globals.assets.setSource(MapSource(set.assets));
  globals.balances.setSource(MapSource(set.balances));
  globals.blocks.setSource(MapSource(set.blocks));
  globals.ciphers.setSource(MapSource(set.ciphers));
  globals.metadatas.setSource(MapSource(set.metadatas));
  globals.passwords.setSource(MapSource(set.passwords));
  globals.rates.setSource(MapSource(set.rates));
  globals.transactions.setSource(MapSource(set.transactions));
  globals.securities.setSource(MapSource(set.securities));
  globals.settings.setSource(MapSource(set.settings));
  globals.vins.setSource(MapSource(set.vins));
  globals.vouts.setSource(MapSource(set.vouts));
  globals.wallets.setSource(MapSource(set.wallets));
}

void useFixtureSources1() => useFixtureSources(1);

void deleteDatabase() => raven_database.deleteDatabase();
