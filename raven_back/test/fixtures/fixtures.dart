export 'accounts.dart';
export 'addresses.dart';
export 'assets.dart';
export 'balances.dart';
export 'blocks.dart';
export 'ciphers.dart';
export 'metadatas.dart';
export 'passwords.dart';
export 'rates.dart';
export 'transactions.dart';
export 'securities.dart';
export 'settings.dart';
export 'vins.dart';
export 'vouts.dart';
export 'wallets.dart';

import 'accounts.dart';
import 'addresses.dart';
import 'assets.dart';
import 'balances.dart';
import 'blocks.dart';
import 'ciphers.dart';
import 'metadatas.dart';
import 'passwords.dart';
import 'rates.dart';
import 'transactions.dart';
import 'securities.dart';
import 'settings.dart';
import 'vins.dart';
import 'vouts.dart';
import 'wallets.dart';

import 'package:reservoir/map_source.dart';
import 'package:raven_back/globals.dart' as globals;
import 'package:raven_back/utils/database.dart' as raven_database;

void useFixtureSources() {
  globals.accounts.setSource(MapSource(accounts));
  globals.addresses.setSource(MapSource(addresses));
  globals.assets.setSource(MapSource(assets));
  globals.balances.setSource(MapSource(balances));
  globals.blocks.setSource(MapSource(blocks));
  globals.ciphers.setSource(MapSource(ciphers));
  globals.metadatas.setSource(MapSource(metadatas));
  globals.passwords.setSource(MapSource(passwords));
  globals.rates.setSource(MapSource(rates));
  globals.transactions.setSource(MapSource(transactions));
  globals.securities.setSource(MapSource(securities));
  globals.settings.setSource(MapSource(settings));
  globals.vins.setSource(MapSource(vins));
  globals.vouts.setSource(MapSource(vouts));
  globals.wallets.setSource(MapSource(wallets));
}

void deleteDatabase() => raven_database.deleteDatabase();
