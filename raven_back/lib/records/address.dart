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
  int hdIndex;

  @HiveField(4)
  NodeExposure exposure;

  @HiveField(5)
  Net net;

  Address({
    required this.scripthash,
    required this.address,
    required this.walletId,
    required this.hdIndex,
    this.exposure = NodeExposure.External,
    this.net = Net.Test,
  });

  @override
  List<Object> get props => [
        scripthash,
        address,
        walletId,
        hdIndex,
        exposure,
        net,
      ];

  @override
  String toString() =>
      'Address($scripthash, $address, $walletId, $hdIndex, $exposure, $net)';

  int compareTo(Address other) {
    if (exposure != other.exposure) {
      return exposure == NodeExposure.Internal ? -1 : 1;
    }
    return hdIndex < other.hdIndex ? -1 : 1;
  }
}
