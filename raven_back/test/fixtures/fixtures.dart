export 'sets.dart';

import 'package:raven_back/reservoirs/cipher.dart';
import 'package:raven_back/reservoirs/security.dart';
import 'package:raven_back/reservoirs/setting.dart';
import 'package:raven_back/reservoirs/reservoirs.dart';

import 'sets.dart';

import 'package:reservoir/map_source.dart';

import 'package:raven_back/utils/database.dart' as raven_database;

/// meant to be used for loading only what the test/group needs. preferred to
/// useFixtureSources because this requires that the app state (contents of the
/// reservoirs) be immediately present near the test and therefore obvious.
void useEmptyFixtures({bool defaults = true}) {
  res.addresses.setSource(MapSource({}));
  res.assets.setSource(MapSource({}));
  res.balances.setSource(MapSource({}));
  res.blocks.setSource(MapSource({}));
  res.ciphers.setSource(MapSource(defaults ? CipherReservoir.defaults : {}));
  res.metadatas.setSource(MapSource({}));
  res.passwords.setSource(MapSource({}));
  res.rates.setSource(MapSource({}));
  res.transactions.setSource(MapSource({}));
  res.securities
      .setSource(MapSource(defaults ? SecurityReservoir.defaults : {}));
  res.settings.setSource(MapSource(defaults ? SettingReservoir.defaults : {}));
  res.vins.setSource(MapSource({}));
  res.vouts.setSource(MapSource({}));
  res.wallets.setSource(MapSource({}));
}

/// meant to be used for any number of complex groupings of app state
void useFixtureSources(int? version) {
  var set = {
        0: FixtureSet0(),
        1: FixtureSet1(),
      }[version] ??
      FixtureSet0();
  res.addresses.setSource(MapSource(set.addresses));
  res.assets.setSource(MapSource(set.assets));
  res.balances.setSource(MapSource(set.balances));
  res.blocks.setSource(MapSource(set.blocks));
  res.ciphers.setSource(MapSource(set.ciphers));
  res.metadatas.setSource(MapSource(set.metadatas));
  res.passwords.setSource(MapSource(set.passwords));
  res.rates.setSource(MapSource(set.rates));
  res.transactions.setSource(MapSource(set.transactions));
  res.securities.setSource(MapSource(set.securities));
  res.settings.setSource(MapSource(set.settings));
  res.vins.setSource(MapSource(set.vins));
  res.vouts.setSource(MapSource(set.vouts));
  res.wallets.setSource(MapSource(set.wallets));
}

void useFixtureSources1() => useFixtureSources(1);
void deleteDatabase() => raven_database.deleteDatabase();
