import 'dart:math';
import 'package:collection/collection.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven_back/raven_back.dart';

part 'account.keys.dart';

class AccountReservoir extends Reservoir<_IdKey, Account> {
  late IndexMultiple<_NameKey, Account> byName;
  late IndexMultiple<_NetKey, Account> byNet;

  AccountReservoir() : super(_IdKey()) {
    byName = addIndexMultiple('name', _NameKey());
    byNet = addIndexMultiple('net', _NetKey());
  }

  String get nextId => (res.accounts.data
              .map((account) => int.parse(account.accountId))
              .toList()
              .reduce(max) +
          1)
      .toString();

  /// returns prefered or first or null account with same net
  Account? getBestAccount(Net net) {
    var netAccounts = res.accounts.byNet.getAll(net);
    for (var netAccount in netAccounts) {
      if (res.settings.primaryIndex
              .getOne(SettingName.Account_Preferred)!
              .value ==
          netAccount.accountId) {
        return netAccount;
      }
    }
    return netAccounts.firstOrNull;
  }
}
