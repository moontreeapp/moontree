import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:client_back/records/types/chain.dart';

import '_type_id.dart';
import 'types/node_exposure.dart';
import 'types/net.dart';

part 'address.g.dart';

@HiveType(typeId: TypeId.Address)
class Address with EquatableMixin {
  @HiveField(0)
  final String scripthash;

  @HiveField(1)
  final String address;

  @HiveField(2)
  final String walletId;

  @HiveField(3)
  final int hdIndex;

  @HiveField(4)
  final NodeExposure exposure;

  @HiveField(5)
  final Net net;

  @HiveField(6, defaultValue: Chain.ravencoin)
  final Chain chain;

  const Address({
    required this.scripthash,
    required this.address,
    required this.walletId,
    required this.hdIndex,
    required this.exposure,
    required this.net,
    required this.chain,
  });

  @override
  List<Object> get props => <Object>[
        scripthash,
        address,
        walletId,
        hdIndex,
        exposure,
        net,
        chain,
      ];

  @override
  String toString() =>
      'Address(scripthash: $scripthash, address: $address, walletId: $walletId, '
      'hdIndex: $hdIndex, exposure: $exposure, chain: $chain, net: $net)';

  int compareTo(Address other) {
    if (exposure != other.exposure) {
      return exposure == NodeExposure.internal ? -1 : 1;
    }
    return hdIndex < other.hdIndex ? -1 : 1;
  }

  String get id => key(scripthash, chain, net);

  static String key(String scripthash, Chain chain, Net net) =>
      '$scripthash:${ChainNet(chain, net).key}';
}
