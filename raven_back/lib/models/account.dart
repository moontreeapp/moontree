import 'package:equatable/equatable.dart';
import 'package:raven/models/balance.dart';
import 'package:raven/records.dart' as records;

// ignore: must_be_immutable
class Account extends Equatable {
  final String name;
  // we have to keep track of balance per asset so we can sum their USD values
  late List<Balance> balances;

  /// presumed
  //final Map<String, dynamic> settings;
  //final Map<String, dynamic> metadata;

  Account({required this.name}) : super();

  factory Account.fromRecord(records.Account record) {
    return Account(name: record.name);
  }

  records.Account toRecord() {
    return records.Account(name: name);
  }

  @override
  List<Object?> get props => [name];

  String get id => name;

  // in usd ( could have multiple assets )
  double get balanceUSD {
    //for each wallet in every list, sum each asset balance (including raven)
    //for each asset, convert to USD, sum

    // the above list should be found in balances if we want to do it that way
    return 0.0;
  }

  double get balanceRVN {
    //for each wallet in every list, sum balance of RVN
    return 0.0;
  }

  double getBalanceOf(String ticker) {
    //for each wallet in every list, sum balance of that asset
    return 0.0;
  }

  //// Sending Functionality ///////////////////////////////////////////////////

  /*
  get sorted list of unspents for all addresses belonging to all wallets with 
  account name.

  var unspents = histories.unspentsByAccount(accountId: name);....
  */

  //SortedList<ScripthashUnspent> sortedUTXOs() {
  //  var sortedList = SortedList<ScripthashUnspent>(
  //      (ScripthashUnspent a, ScripthashUnspent b) =>
  //          a.value.compareTo(b.value));
  //  sortedList.addAll(
  //      Truth.instance.accountUnspents.getAsList<ScripthashUnspent>(accountId));
  //  return sortedList;
  //}

  ///// returns the smallest number of inputs to satisfy the amount
  //List<ScripthashUnspent> collectUTXOs(int amount,
  //    [List<ScripthashUnspent>? except]) {
  //  var ret = <ScripthashUnspent>[];
  //  if (balance < amount) {
  //    throw InsufficientFunds();
  //  }
  //  var utxos = sortedUTXOs();
  //  utxos.removeWhere((utxo) => (except ?? []).contains(utxo));
  //  /* can we find an ideal singular utxo? */
  //  for (var i = 0; i < utxos.length; i++) {
  //    if (utxos[i].value >= amount) {
  //      return [utxos[i]];
  //    }
  //  }
  //  /* what combinations of utxo's must we return?
  //  lets start by grabbing the largest one
  //  because we know we can consume it all without producing change...
  //  and lets see how many times we can do that */
  //  var remainder = amount;
  //  for (var i = utxos.length - 1; i >= 0; i--) {
  //    if (remainder < utxos[i].value) {
  //      break;
  //    }
  //    ret.add(utxos[i]);
  //    remainder = (remainder - utxos[i].value).toInt();
  //  }
  //  // Find one last UTXO, starting from smallest, that satisfies the remainder
  //  ret.add(utxos.firstWhere((utxo) => utxo.value >= remainder));
  //  return ret;
  //}
}
