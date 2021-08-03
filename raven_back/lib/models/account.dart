/// TODO:
/// commented out code is for if we really wanted the entire objects... do we?

import 'package:equatable/equatable.dart';
import 'package:raven/records.dart' as records;
//import 'package:raven/models/leader_wallet.dart';
//import 'package:raven/wallets/pk_wallet.dart';

class Account extends Equatable {
  final String name;
  final List<String> leaderWalletIds;
  final List<String> privateKeyWalletIds;
  //final List<LeaderWallet> leaderWallets;
  //final List<PrivateKeyWallet> privateKeyWallets;

  Account(this.name,
      [List<String>? leaderWalletList, List<String>? privateKeyWalletList])
      : leaderWalletIds = leaderWalletList ?? [],
        privateKeyWalletIds = privateKeyWalletList ?? [],
        super();
  //Account(this.name,
  //    [List<LeaderWallet>? leaderWalletList,
  //    List<PrivateKeyWallet>? privateKeyWalletList])
  //    : leaderWallets = leaderWalletList ?? [],
  //      privateKeyWallets = privateKeyWalletList ?? [],
  //      super();

  factory Account.fromRecord(records.Account record) {
    return Account(
        record.name, record.leaderWalletIds, record.privateKeyWalletIds);
  }
  //factory Account.fromRecord(records.Account record) {
  //  var leaders = record.leaderWalletIds.map((id) => get the wallet object using a servcie?).toList();
  //  var keys = record.privateKeyWalletIds.map((id) => get the wallet object using a servcie?).toList();
  //  return Account(record.name, leaders, keys);
  //}

  records.Account toRecord() {
    return records.Account(name, leaderWalletIds, privateKeyWalletIds);
  }
  //records.Account toRecord() {
  //    return records.Account(
  //        name,
  //        leaderWallets.map((wallet) => wallet.id).toList(),
  //        privateKeyWallets.map((wallet) => wallet.id).toList());
  //  }

  @override
  List<Object?> get props => [name];

  //int get balance => for each wallet in both lists, sum balance;

}
