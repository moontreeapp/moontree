import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:electrum_adapter/electrum_adapter.dart';

import '_type_id.dart';

part 'block.g.dart';

@HiveType(typeId: TypeId.Block)
class Block with EquatableMixin, ToStringMixin {
  final int height;

  // what information do we need about blockchain? just current height I think.
  //@HiveField(1)
  //final int hex or blocktime or... idk;

  const Block({required this.height});

  factory Block.fromBlockHeader(BlockHeader blockHeader) =>
      Block(height: blockHeader.height);
  @HiveField(0)
  @override
  List<Object?> get props => <Object?>[height];

  @override
  List<String> get propNames => <String>['height'];

  String get id => Block.blockKey();

  static String blockKey() => 'height';
}
