import 'package:raven/models.dart';
import 'package:raven/reservoir/reservoir.dart';

class WalletReservoir extends Reservoir {
  WalletReservoir([source])
      : super(source ?? HiveBoxSource('wallets'), (wallet) => wallet.id) {
    mapToModel = (record) => (record.isHD
        ? LeaderWallet.fromRecord(record)
        : SingleWallet.fromRecord(record));
    mapToRecord = (model) => (model as dynamic).toRecord();
  }
}
