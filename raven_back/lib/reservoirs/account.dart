import 'package:collection/collection.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';
import 'package:raven/records/records.dart';

part 'account.keys.dart';

class AccountReservoir extends Reservoir<_IdKey, Account> {
  AccountReservoir() : super(_IdKey());
}
