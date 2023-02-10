import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moontree_utils/extensions/string.dart';
import 'package:moontree_utils/extensions/uint8list.dart';
import 'package:wallet_utils/src/utilities/address.dart';
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
  final String pubkey;

  @HiveField(2)
  final String walletId;

  @HiveField(3)
  final int index;

  @HiveField(4)
  final NodeExposure exposure;

  const Address({
    this.scripthash = '',
    required this.pubkey,
    required this.walletId,
    required this.exposure,
    required this.index,
    this.error,
  });

  final String? error;

  @override
  List<Object> get props => <Object>[
        scripthash,
        pubkey,
        walletId,
        exposure,
        index,
      ];

  @override
  String toString() => 'Address(scripthash: $scripthash, pubkey: $pubkey, '
      'walletId: $walletId,  exposure: $exposure, index: $index)';

  factory Address.empty() => Address(
        scripthash: '',
        pubkey: '',
        walletId: '',
        index: 0,
        exposure: NodeExposure.external,
      );

  Address create({
    String? scripthash,
    String? pubkey,
    String? walletId,
    int? index,
    NodeExposure? exposure,
    String? error,
  }) =>
      Address(
        scripthash: scripthash ?? this.scripthash,
        pubkey: pubkey ?? this.pubkey,
        walletId: walletId ?? this.walletId,
        index: index ?? this.index,
        exposure: exposure ?? this.exposure,
        error: error ?? this.error,
      );

  int compareTo(Address other) {
    if (exposure != other.exposure) {
      return exposure == NodeExposure.internal ? -1 : 1;
    }
    return index < other.index ? -1 : 1;
  }

  String get id => key(walletId, exposure, index);
  static String key(String walletId, NodeExposure exposure, int index) =>
      '$walletId:$exposure:$index';

  String get walletExposureId => walletExposureKey(walletId, exposure);
  static String walletExposureKey(String walletId, NodeExposure exposure) =>
      '$walletId:$exposure';

  Uint8List get h160 => hash160(pubkey);
  String get h160AsString =>
      hex.encode(h160); // right? only used on subscription.
  ByteData get h160AsByteData => h160.buffer.asByteData();

  /// returns the address representation according to chain and net
  String address(Chain chain, Net net, {bool isP2sh = false}) => h160ToAddress(
      h160: h160,
      addressType: isP2sh
          ? ChainNet(chain, net).chaindata.p2shPrefix
          : ChainNet(chain, net).chaindata.p2pkhPrefix);

  static String addressFrom(
    Uint8List h160AsUint8List,
    Chain chain,
    Net net, {
    bool isP2sh = false,
  }) =>
      h160AsUint8List.h160ToAddress(isP2sh
          ? ChainNet(chain, net).chaindata.p2shPrefix
          : ChainNet(chain, net).chaindata.p2pkhPrefix);
}
