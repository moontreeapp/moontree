import 'package:equatable/equatable.dart';
import 'package:raven/models/balance.dart';
import 'package:raven/records.dart' as records;

// ignore: must_be_immutable
class Account extends Equatable {
  final String accountId;
  final String name;
  // could move into balances reservoir if we want
  late Map<String, Balance> balances;

  Account({required this.accountId, required this.name, balances})
      : balances = balances ?? {},
        super();

  factory Account.fromRecord(records.Account record) {
    var newBalances = {} as Map<String, Balance>;
    record.balances.forEach((key, balance) {
      newBalances[key] = Balance.fromRecord(balance);
    });
    return Account(
        accountId: record.accountId, name: record.name, balances: newBalances);
  }

  records.Account toRecord() {
    var newBalances = {} as Map<String, records.Balance>;
    balances.forEach((key, balance) {
      newBalances[key] = balance.toRecord();
    });
    return records.Account(
        accountId: accountId, name: name, balances: newBalances);
  }

  @override
  List<Object?> get props => [accountId];

  String get id => accountId;

  Balance get balance => getRVN();

  /// get rvn confirmed and unconfirmed of assets from own trading platform
  Balance getTotalRVN() {
    var rvn = Balance(confirmed: 0, unconfirmed: 0);
    balances.forEach((asset, balance) {
      if (asset == '') {
        rvn = rvn + balance;
      } else {
        //rvn = rvn + fromAssetToRVN(asset, balance);
      }
    });
    return rvn;
  }

  Balance getRVN() {
    return balances[''] ?? Balance(confirmed: 0, unconfirmed: 0);
  }
}
