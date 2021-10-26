export 'accounts.dart';
export 'addresses.dart';
export 'balances.dart';
// export 'histories.dart';
export 'wallets.dart';

import 'accounts.dart';
import 'addresses.dart';
import 'balances.dart';
// import 'histories.dart';
import 'wallets.dart';

import 'package:raven/globals.dart' as globals;

void useFixtureSources() {
  globals.accounts.setSource(accounts());
  globals.wallets.setSource(wallets());
  globals.addresses.setSource(addresses());
  // globals.histories.setSource(histories());
  globals.balances.setSource(balances());
}
