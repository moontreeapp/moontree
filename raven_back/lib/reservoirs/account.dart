import 'dart:math';
import 'package:collection/collection.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';

part 'account.keys.dart';

class AccountReservoir extends Reservoir<_IdKey, Account> {
  late IndexMultiple<_NameKey, Account> byName;

  AccountReservoir() : super(_IdKey()) {
    byName = addIndexMultiple('name', _NameKey());
  }

  String get nextId => (accounts.data
              .map((account) => int.parse(account.accountId))
              .toList()
              .reduce(max) +
          1)
      .toString();
}
