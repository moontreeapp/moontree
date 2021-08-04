import 'package:hive/hive.dart';
import 'package:raven/models/balance.dart';

import 'node_exposure.dart';
import 'net.dart';

part 'address.g.dart';

@HiveType(typeId: 3)
class Address {
  @HiveField(0)
  String scripthash;

  @HiveField(1)
  String address;

  @HiveField(2)
  String walletId;

  @HiveField(3)
  int hdIndex;

  @HiveField(4)
  NodeExposure exposure;

  @HiveField(5)
  Net net;

  @HiveField(6)
  Balance? balance;

  Address(
    this.scripthash,
    this.address,
    this.walletId,
    this.hdIndex, {
    this.exposure = NodeExposure.External,
    this.net = Net.Test,
    this.balance,
  });
}
