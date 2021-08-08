/// the purpose of this service is to provide a list of unspents by account
import 'dart:async';

import 'package:raven/models/history.dart';
import 'package:raven/reservoirs/account.dart';
import 'package:raven/reservoirs/history.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/exceptions.dart';
import 'package:sorted_list/sorted_list.dart';

class AccountService extends Service {
  AccountReservoir accounts;
  HistoryReservoir histories;

  AccountService(this.accounts, this.histories) : super();

  @override
  Future init() async {
    // no listeners for now
  }

  @override
  void deinit() {
    // no listeners for now
  }

  SortedList<History> sortedUTXOs(String accountId) {
    var sortedList = SortedList<History>(
        (History a, History b) => a.value.compareTo(b.value));
    sortedList.addAll(histories.unspentsByAccount(accountId));
    return sortedList;
  }

  /// returns the smallest number of inputs to satisfy the amount
  List<History> collectUTXOs(String accountId, int amount,
      [List<History>? except]) {
    var account = accounts.get(accountId);
    var ret = <History>[];
    if (account.balance < amount) {
      throw InsufficientFunds();
    }
    var utxos = sortedUTXOs(accountId);
    utxos.removeWhere((utxo) => (except ?? []).contains(utxo));
    /* can we find an ideal singular utxo? */
    for (var i = 0; i < utxos.length; i++) {
      if (utxos[i].value >= amount) {
        return [utxos[i]];
      }
    }
    /* what combinations of utxo's must we return?
    lets start by grabbing the largest one
    because we know we can consume it all without producing change...
    and lets see how many times we can do that */
    var remainder = amount;
    for (var i = utxos.length - 1; i >= 0; i--) {
      if (remainder < utxos[i].value) {
        break;
      }
      ret.add(utxos[i]);
      remainder = (remainder - utxos[i].value).toInt();
    }
    // Find one last UTXO, starting from smallest, that satisfies the remainder
    ret.add(utxos.firstWhere((utxo) => utxo.value >= remainder));
    return ret;
  }
}
