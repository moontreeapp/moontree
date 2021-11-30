export 'accounts.dart';
export 'addresses.dart';
export 'balances.dart';
// export 'histories.dart';
export 'wallets.dart';
export 'securities.dart';

import 'accounts.dart';
import 'addresses.dart';
import 'balances.dart';
// import 'histories.dart';
import 'wallets.dart';
// import 'securities.dart';

import 'package:reservoir/map_source.dart';
import 'package:raven_back/globals.dart' as globals;

void useFixtureSources() {
  globals.accounts.setSource(MapSource(accounts()));
  globals.wallets.setSource(wallets());
  globals.addresses.setSource(addresses());
  // globals.histories.setSource(histories());
  globals.balances.setSource(balances());
}
