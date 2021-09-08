import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '_type_id.dart';
import 'node_exposure.dart';
import 'net.dart';

part 'address.g.dart';

@HiveType(typeId: TypeId.Address)
class Address with EquatableMixin {
  @HiveField(0)
  String scripthash; // change to addressId?

  @HiveField(1)
  String address;

  @HiveField(2)
  String walletId;

  @HiveField(3)
  String accountId;

  @HiveField(4)
  int hdIndex;

  @HiveField(5)
  NodeExposure exposure;

  @HiveField(6)
  Net net;

  Address({
    required this.scripthash,
    required this.address,
    required this.walletId,
    required this.accountId,
    required this.hdIndex,
    this.exposure = NodeExposure.External,
    this.net = Net.Test,
  });

  @override
  List<Object> get props => [
        scripthash,
        address,
        walletId,
        accountId,
        hdIndex,
        exposure,
        net,
      ];

  @override
  String toString() =>
      'Address($scripthash, $address, $walletId, $accountId, $hdIndex, $exposure, $net)';
}
