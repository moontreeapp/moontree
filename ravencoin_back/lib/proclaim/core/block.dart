/// this really is just a header object - we could call it headers Proclaim...
import 'package:collection/collection.dart';
import 'package:ravencoin_back/records/records.dart';
import 'package:proclaim/proclaim.dart';

part 'block.keys.dart';

class BlockProclaim extends Proclaim<_HeaderKey, Block> {
  BlockProclaim() : super(_HeaderKey());

  // should be a list of one item since the key is hard coded, should replace it
  Block? latest(Chain chain, Net net) =>
      primaryIndex.getByKeyStr(Block.key(chain, net)).firstOrNull;
}
