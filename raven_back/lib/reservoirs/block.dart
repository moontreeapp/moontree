/// this really is just a header object - we could call it headers reservoir...
import 'package:collection/collection.dart';
import 'package:raven/records/records.dart';
import 'package:reservoir/reservoir.dart';

part 'block.keys.dart';

class BlockReservoir extends Reservoir<_HeaderKey, Block> {
  BlockReservoir() : super(_HeaderKey());

  // should be a list of one item since the key is hard coded, should replace it
  Block? get latest => primaryIndex.getByKeyStr(_headerToKey()).firstOrNull;
}
