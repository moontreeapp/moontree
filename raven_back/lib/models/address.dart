import '../records/node_exposure.dart';
import '../records/net.dart';
import '../records.dart' as records;
import 'balance.dart';

class Address {
  final String scripthash;
  final String address;
  final String walletId;
  final int hdIndex;
  late NodeExposure exposure;
  late Net net;
  late Balance? balance;

  Address(this.scripthash, this.address, this.walletId, this.hdIndex,
      {this.exposure = NodeExposure.External,
      this.net = Net.Test,
      this.balance});

  factory Address.fromRecord(records.Address record) {
    return Address(
        record.scripthash, record.address, record.walletId, record.hdIndex,
        exposure: record.exposure, net: record.net, balance: record.balance);
  }

  records.Address toRecord() {
    return records.Address(scripthash, address, walletId, hdIndex,
        exposure: exposure, net: net, balance: balance);
  }
}
