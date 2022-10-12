import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_electrum/ravencoin_electrum.dart';

import '_type_id.dart';

part 'block.g.dart';

@HiveType(typeId: TypeId.Block)
class Block with EquatableMixin, ToStringMixin {
  @HiveField(0)
  final int height;

  @HiveField(1, defaultValue: Chain.ravencoin)
  final Chain chain;

  @HiveField(2, defaultValue: Net.Main)
  final Net net;

  // what information do we need about blockchain? just current height I think.
  //@HiveField(1)
  //final int hex or blocktime or... idk;

  Block({required this.height, required this.chain, required this.net});

  @override
  List<Object?> get props => [height, chain, net];

  @override
  List<String> get propNames => ['height', 'chain', 'net'];

  factory Block.fromBlockHeader(BlockHeader blockHeader) => Block(
        height: blockHeader.height,
        chain: pros.settings.chain,
        net: pros.settings.net,
      );

  String get id => Block.key(chain, net);

  static String key(Chain chain, Net net) => '${chain.name}:${net.name}';
}
