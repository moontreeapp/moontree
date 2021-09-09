export 'addresses.dart';
export 'balances.dart';
export 'histories.dart';
export 'wallets.dart';

import 'addresses.dart';
import 'balances.dart';
import 'histories.dart';
import 'wallets.dart';

import 'package:raven/globals.dart' as globals;

void useFixtureSources() {
  globals.addresses.setSource(addresses());
  globals.balances.setSource(balances());
  globals.histories.setSource(histories());
  globals.wallets.setSource(wallets());
}
