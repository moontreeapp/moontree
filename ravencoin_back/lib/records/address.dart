import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/records/types/chain.dart';

import '_type_id.dart';
import 'types/node_exposure.dart';
import 'types/net.dart';

part 'address.g.dart';

@HiveType(typeId: TypeId.Address)
class Address with EquatableMixin {
  @HiveField(0)
  String id;

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
  Chain chain;

  Address({
    required this.id,
    required this.address,
    required this.walletId,
    required this.hdIndex,
    required this.exposure,
    required this.chain,
    required this.net,
  });

  @override
  List<Object> get props => [
        id,
        address,
        walletId,
        hdIndex,
        exposure,
        net,
      ];

  @override
  String toString() =>
      'Address(id: $id, address: $address, walletId: $walletId, '
      'hdIndex: $hdIndex, exposure: $exposure, net: $net)';

  int compareTo(Address other) {
    if (exposure != other.exposure) {
      return exposure == NodeExposure.internal ? -1 : 1;
    }
    return hdIndex < other.hdIndex ? -1 : 1;
  }

  String get scripthash => id;

  String get uid => key(scripthash, chain, net);

  static String key(String scripthash, Chain chain, Net net) =>
      '$scripthash:${chainNetKey(chain, net)}';
}
