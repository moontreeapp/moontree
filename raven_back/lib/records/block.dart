import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import '_type_id.dart';

part 'block.g.dart';

@HiveType(typeId: TypeId.Block)
class Block with EquatableMixin {
  @HiveField(0)
  final String hex;

  @HiveField(1)
  final int height;

  Block({required this.hex, required this.height});

  @override
  List<Object> get props => [hex, height];

  @override
  String toString() => 'Balance($hex, $height)';

  factory Block.fromBlockHeader(BlockHeader blockHeader) {
    return Block(hex: blockHeader.hex, height: blockHeader.height);
  }
}
