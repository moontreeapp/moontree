import 'package:raven/records.dart' as records;
import 'package:raven/models.dart';
import 'package:raven/reservoir/reservoir.dart';

class WalletReservoir extends Reservoir<String, records.Wallet, dynamic> {
  // indices?

  WalletReservoir([source]) : super(source ?? HiveSource('wallets')) {
    toModel = (record) => (record.isHD
        ? LeaderWallet.fromRecord(record)
        : SingleWallet.fromRecord(record));
    toRecord = (model) => (model as dynamic).toRecord();
  }
}