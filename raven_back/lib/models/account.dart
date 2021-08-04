import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:raven/records.dart' as records;

class Account extends Equatable {
  final String name;
  final List<String> leaderWalletIds; // children
  final List<String> derivedWalletIds; // imported
  final List<String> privateKeyWalletIds; // imported

  Account(this.name,
      [List<String>? leaderWalletList,
      List<String>? derivedWalletList,
      List<String>? privateKeyWalletList])
      : leaderWalletIds = leaderWalletList ?? [],
        derivedWalletIds = derivedWalletList ?? [],
        privateKeyWalletIds = privateKeyWalletList ?? [],
        super();

  factory Account.fromRecord(records.Account record) {
    return Account(record.name, record.leaderWalletIds, record.derivedWalletIds,
        record.privateKeyWalletIds);
  }

  records.Account toRecord() {
    return records.Account(
        name, leaderWalletIds, derivedWalletIds, privateKeyWalletIds);
  }

  @override
  List<Object?> get props => [name];

  // in usd ( could have multiple assets )
  double get balanceUSD {
    //for each wallet in every list, sum each asset balance (including raven)
    //for each asset, convert to USD, sum
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
}
