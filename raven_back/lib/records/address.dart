import 'dart:math';

import 'package:hive/hive.dart';

import 'node_exposure.dart';
import 'net.dart';

part 'address.g.dart';

@HiveType(typeId: 1)
class Address {
  @HiveField(0)
  String scripthash;

  @HiveField(1)
  String accountId;

  @HiveField(2)
  int hdIndex;

  @HiveField(3)
  NodeExposure exposure;

  @HiveField(4)
  Net net;

  Address(
    this.scripthash,
    this.accountId,
    this.hdIndex, {
    this.net = Net.Test,
    this.exposure = NodeExposure.External,
  });
}
