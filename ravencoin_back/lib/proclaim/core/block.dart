/// this really is just a header object - we could call it headers Proclaim...
import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:ravencoin_back/records/records.dart';

part 'block.keys.dart';

class BlockProclaim extends Proclaim<_IdKey, Block> {
  BlockProclaim() : super(_IdKey());

  // should be a list of one item since the key is hard coded, should replace it
  Block? get latest => primaryIndex.getByKeyStr(Block.blockKey()).firstOrNull;
}
