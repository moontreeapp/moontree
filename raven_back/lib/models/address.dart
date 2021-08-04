import '../records/node_exposure.dart';
import '../records/net.dart';
import '../records.dart' as records;
import 'balance.dart';

class Address {
  final String scripthash;
  final String address;
  final String walletId;
  final String accountId;
  final int hdIndex;
  late NodeExposure exposure;
  late Net net;
  late Balance? balance;

  Address(
      {required this.scripthash,
      required this.address,
      required this.walletId,
      required this.accountId,
      required this.hdIndex,
      this.exposure = NodeExposure.External,
      this.net = Net.Test,
      this.balance});

  factory Address.fromRecord(records.Address record) {
    return Address(
        scripthash: record.scripthash,
        address: record.address,
        walletId: record.walletId,
        accountId: record.accountId,
        hdIndex: record.hdIndex,
        exposure: record.exposure,
        net: record.net,
        balance: record.balance);
  }

  records.Address toRecord() {
    return records.Address(
        scripthash: scripthash,
        address: address,
        walletId: walletId,
        accountId: accountId,
        hdIndex: hdIndex,
        exposure: exposure,
        net: net,
        balance: balance);
  }
}
