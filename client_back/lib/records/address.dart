import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moontree_utils/extensions/string.dart';
import 'package:client_back/utilities/address.dart';
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
  final String h160;

  @HiveField(2)
  final String walletId;

  @HiveField(3)
  final int index;

  @HiveField(4)
  final NodeExposure exposure;

  const Address({
    this.scripthash = '',
    required this.h160,
    required this.walletId,
    required this.exposure,
    required this.index,
  });

  @override
  List<Object> get props => <Object>[
        scripthash,
        h160,
        walletId,
        exposure,
        index,
      ];

  @override
  String toString() => 'Address(scripthash: $scripthash, h160: $h160, '
      'walletId: $walletId,  exposure: $exposure, index: $index)';

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

  factory Address.empty() => Address(
        scripthash: '',
        h160: '',
        walletId: '',
        index: 0,
        exposure: NodeExposure.external,
      );

  Uint8List get h160AsUint8List => h160.hexToUint8List;
  ByteData get h160AsByteData => h160AsUint8List.buffer.asByteData();

  /// returns the address representation according to chain and net
  String address(Chain chain, Net net, {bool isP2sh = false}) => h160ToAddress(
      h160: h160AsUint8List,
      addressType: isP2sh
          ? ChainNet(chain, net).chaindata.p2shPrefix
          : ChainNet(chain, net).chaindata.p2pkhPrefix);
}
