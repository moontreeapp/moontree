import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import '_type_id.dart';

part 'block.g.dart';

@HiveType(typeId: TypeId.Block)
class Block with EquatableMixin {
  @HiveField(0)
  final int height;

  // what information do we need about blockchain? just current height I think.
  //@HiveField(1)
  //final int hex or blocktime or... idk;

  Block({required this.height});

  @override
  List<Object> get props => [height];

  @override
  String toString() => 'Balance($height)';

  factory Block.fromBlockHeader(BlockHeader blockHeader) {
    return Block(height: blockHeader.height);
  }
}
