import 'package:hive/hive.dart';

import 'node_exposure.dart';
import 'net.dart';

part 'address.g.dart';

@HiveType(typeId: 1)
class Address {
  @HiveField(0)
  String scripthash;

  @HiveField(1)
  String address;

  @HiveField(2)
  String accountId;

  @HiveField(3)
  int hdIndex;

  @HiveField(4)
  NodeExposure exposure;

  @HiveField(5)
  Net net;

  Address(
    this.scripthash,
    this.address,
    this.accountId,
    this.hdIndex, {
    this.net = Net.Test,
    this.exposure = NodeExposure.External,
  });
}
