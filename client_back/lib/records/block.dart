import 'package:client_back/server/src/protocol/protocol.dart' as protocol;
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

  const Block({this.height = 0});

  /// from electurm
  factory Block.fromBlockHeader(BlockHeader blockHeader) =>
      Block(height: blockHeader.height);

  /// from moontree server
  factory Block.fromNotification(protocol.NotifyChainHeight message) =>
      Block(height: message.height);

  @HiveField(0)
  @override
  List<Object?> get props => <Object?>[height];

  @override
  List<String> get propNames => <String>['height'];

  String get id => Block.blockKey();

  static String blockKey() => 'height';
}
