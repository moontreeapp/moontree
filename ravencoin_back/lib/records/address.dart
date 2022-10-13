import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/records/types/chain.dart';

import '_type_id.dart';
import 'types/node_exposure.dart';
import 'types/net.dart';

part 'address.g.dart';

@HiveType(typeId: TypeId.Address)
class Address with EquatableMixin {
  /// we did not have the foresight to realize we might want to change this id
  /// for address or wallet so the id is the scripthash in this case and we key
  /// join and things off .idKey because .idKey is a function and can be
  /// modified to reflect any uniquely identifying set of attributes.
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

  @HiveField(6, defaultValue: Chain.ravencoin)
  Chain chain;

  /// rather than dealing with the complexity of migrating we'll use .idKey
  //@HiveField(7, defaultValue: '')
  //String scripthash;

  Address({
    required this.id,
    required this.address,
    required this.walletId,
    required this.hdIndex,
    required this.exposure,
    required this.net,
    required this.chain,
    //required this.scripthash,
  });

  @override
  List<Object> get props => [
        id,
        address,
        walletId,
        hdIndex,
        exposure,
        net,
        chain,
        //scripthash,
      ];

  @override
  String toString() =>
      'Address(id: $id, address: $address, walletId: $walletId, '
      'hdIndex: $hdIndex, exposure: $exposure, ${chainNetReadable(chain, net)})';
  //'scripthash: $scripthash)';

  factory Address.from(
    Address address, {
    String? id,
    String? addressAddress,
    String? walletId,
    int? hdIndex,
    NodeExposure? exposure,
    Net? net,
    Chain? chain,
    //String? scripthash,
  }) =>
      Address(
        id: id ?? address.idKey,
        address: addressAddress ?? address.address,
        walletId: walletId ?? address.walletId,
        hdIndex: hdIndex ?? address.hdIndex,
        exposure: exposure ?? address.exposure,
        net: net ?? address.net,
        chain: chain ?? address.chain,
        //scripthash: scripthash ?? address.scripthash,
      );

  String get idKey => Address.key(id, chain, net);

  static String key(String scripthash, Chain chain, Net net) =>
      '$scripthash:${chainNetKey(chain, net)}';

  int compareTo(Address other) {
    if (exposure != other.exposure) {
      return exposure == NodeExposure.Internal ? -1 : 1;
    }
    return hdIndex < other.hdIndex ? -1 : 1;
  }

  String get scripthash => id; // make a migration process

}
