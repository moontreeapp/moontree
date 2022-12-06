import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:electrum_adapter/electrum_adapter.dart';

import '_type_id.dart';

part 'block.g.dart';

@HiveType(typeId: TypeId.Block)
class Block with EquatableMixin, ToStringMixin {
  @HiveField(0)
  final int height;

  // what information do we need about blockchain? just current height I think.
  //@HiveField(1)
  //final int hex or blocktime or... idk;

  Block({required this.height});

  @override
  List<Object?> get props => <Object?>[height];

  @override
  List<String> get propNames => ['height'];

  factory Block.fromBlockHeader(BlockHeader blockHeader) {
    return Block(height: blockHeader.height);
  }

  String get id => Block.blockKey();

  static String blockKey() => 'height';
}
